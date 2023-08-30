import {ISetRoomRequest} from "../controllers/requests/roomRequests/setRoomRequest";
import {RoomModel} from "../domain/room";
import {IContact, ITag, UserModel} from "../domain/user"
import mongoose, {Types} from "mongoose";
import {TaskModel} from "../domain/task";
import {defaultTags} from "../utils/defaults";
import {IContactResponse, ITagResponse, IUserResponse} from "../controllers/responses/userResponse";
import {mapContactToResponse, mapTagToResponse, mapUserToResponse} from "./mappers/userMapper";
import {ISetContactRequest} from "../controllers/requests/userRequests/setContactRequest";
import {ISetTagRequest} from "../controllers/requests/userRequests/setTagRequest";
import * as crypto from "crypto";
import {deletePhotosBlindSend} from "./photoService";

export async function getUserByFirebaseId(id: string): Promise<IUserResponse> {
    const user = await UserModel.findOne({'firebaseId': id});
    return user ? mapUserToResponse(user) : null;
}

export async function createUser(firebaseId: string, email: string, rooms: ISetRoomRequest[] = []): Promise<IUserResponse> {
    const userById = await UserModel.findOne({'firebaseId': firebaseId});
    if (userById) {
        throw Error(`User already exists with given firebase id: ${firebaseId}`);
    }
    const userByEmail = await UserModel.findOne({'email': email});
    if (userByEmail) {
        throw Error(`User already exists with given email: ${email}`);
    }

    let user = null;
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const roomIds: Types.ObjectId[] = [];
        if (rooms.length) {
            for (const room of rooms) {
                const createdRoom = new RoomModel({
                        name: room.name,
                        note: room.note,
                        createdBy: firebaseId,
                        tasks: []
                    }
                );
                await createdRoom.save({session});
                roomIds.push(createdRoom._id);
            }
        }

        user = new UserModel({
            firebaseId: firebaseId,
            email: email,
            contacts: [],
            rooms: roomIds,
            tags: defaultTags,
            tasks: []
        });
        await user.save({session});

        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
        // todo is there a way to just wrap all db actions in one transaction block? would avoid this ugly throwing
    }

    return mapUserToResponse(user);
}

export async function createTag(name: string, firebaseId: string): Promise<ITagResponse> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const tag = {id: crypto.randomUUID(), name: name, tasks: [] as Types.ObjectId[]} as ITag;
    user.tags.push(tag);
    await user.save();
    return mapTagToResponse(tag);
}

export async function updateTag(tagId: string, request: ISetTagRequest, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': firebaseId});
        const tag = user.tags.find(x => x.id === tagId);

        tag.name = request.name;
        await user.save({session});

        // update all tasks that this tag belongs to with the new name
        await TaskModel.updateMany(
            {'_id': {$in: tag.tasks}},
            {$set: {'tags.$[element].name': tag.name}},
            {arrayFilters: [{'element.id': tagId}]}
        ).session(session);


        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
    }
}

export async function deleteTag(tagId: string, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const user = await UserModel.findOne({'firebaseId': firebaseId}).session(session);

        const tagToDelete = user.tags.find(x => x.id === tagId);
        user.tags = user.tags.filter(x => x.id !== tagId);
        await user.save({session});

        // remove tags from all tasks it is associated with
        await TaskModel.updateMany(
            {'_id': {$in: tagToDelete.tasks}},
            {$pull: {'tags': {'id': tagId}}}
        ).session(session);

        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
    }
}

export async function createContact(name: string, email: string, phoneNumber: string, firebaseId: string): Promise<IContactResponse> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const contact = {
        id: crypto.randomUUID(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        tasks: [] as Types.ObjectId[]
    } as IContact;
    user.contacts.push(contact);
    await user.save();
    return mapContactToResponse(contact);
}

export async function updateContact(contactId: string, request: ISetContactRequest, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': firebaseId}).session(session);
        const contact = user.contacts.find(x => x.id === contactId);
        contact.name = request.name;
        contact.phoneNumber = request.phoneNumber;
        contact.email = request.email;
        await user.save({session});

        // update all tasks that this contact belongs to with the new fields
        await TaskModel.updateMany(
            {'_id': {$in: contact.tasks}},
            {
                $set: {
                    'contacts.$[element].name': contact.name,
                    'contacts.$[element].email': contact.email,
                    'contacts.$[element].phoneNumber': contact.phoneNumber
                }
            },
            {arrayFilters: [{'element.id': {$eq: contactId}}]}
        ).session(session);

        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
    }
}

export async function deleteContact(contactId: string, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': firebaseId}).session(session);

        const contactToDelete = user.contacts.find(x => x.id === contactId);
        user.contacts = user.contacts.filter(x => x.id !== contactId);
        await user.save({session});

        // remove tags from all tasks it is associated with
        await TaskModel.updateMany(
            {'_id': {$in: contactToDelete.tasks}},
            {$pull: {'contacts': {'id': contactId}}}
        ).session(session);

        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
    }
}

export async function deleteUser(firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const user = await UserModel.findOneAndDelete({'firebaseId': firebaseId}).session(session);

        // delete all tasks and rooms from user
        await TaskModel.deleteMany({'_id': {$in: user.tasks}}).session(session);
        await RoomModel.deleteMany({'_id': {$in: user.rooms}}).session(session);
        // todo delete completed tasks (denormalize on user? maybe just don't return it to frontend since its not needed. or just do a count)
        deletePhotosBlindSend({taskIds: user.tasks.map(e => e.toHexString()), firebaseId: firebaseId});

        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
        throw e;
    }
}
