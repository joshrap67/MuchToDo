import {SetRoomRequest} from "../controllers/requests/roomRequests/setRoomRequest";
import {RoomModel} from "../domain/room";
import {Contact, Tag, UserModel} from "../domain/user"
import mongoose, {Types} from "mongoose";
import {TaskModel} from "../domain/task";
import {defaultTags} from "../utils/defaults";
import {ContactResponse, TagResponse, UserResponse} from "../controllers/responses/userResponse";
import {mapContactToResponse, mapTagToResponse, mapUserToResponse} from "./mappers/userMapper";
import {SetContactRequest} from "../controllers/requests/userRequests/setContactRequest";
import {SetTagRequest} from "../controllers/requests/userRequests/setTagRequest";
import * as crypto from "crypto";
import {deletePhotosBlindSend} from "./photoService";
import {BadRequestException} from "../errors/exceptions/badRequestException";
import {maxContacts, maxTags} from "../utils/constants";
import {CompletedTaskModel} from "../domain/completedTask";
import admin from "firebase-admin";
import {ResourceNotFoundException} from "../errors/exceptions/resourceNotFoundException";

export async function getUserById(id: string): Promise<UserResponse> {
    const user = await UserModel.findOne({'_id': id});
    if (!user) {
        throw new ResourceNotFoundException('User not found');
    }
    return mapUserToResponse(user);
}

export async function createUser(firebaseId: string, email: string, rooms: SetRoomRequest[] = []): Promise<UserResponse> {
    const userById = await UserModel.findOne({'_id': firebaseId});
    if (userById) {
        throw new BadRequestException(`User already exists with given firebase id: ${firebaseId}`);
    }
    const userByEmail = await UserModel.findOne({'email': email});
    if (userByEmail) {
        throw new BadRequestException(`User already exists with given email: ${email}`);
    }

    let userResponse;
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
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

            const user = new UserModel({
                _id: firebaseId,
                email: email,
                contacts: [],
                rooms: roomIds,
                tags: defaultTags,
                tasks: []
            });
            await user.save({session});
            userResponse = mapUserToResponse(user);
        });
    } finally {
        await session.endSession();
    }

    return userResponse;
}

export async function createTag(name: string, userId: string): Promise<TagResponse> {
    const user = await UserModel.findOne({'_id': userId});
    if (user.tags.length > maxTags) {
        throw new BadRequestException(`Cannot have more than ${maxTags} tags`);
    }

    const tag = {id: crypto.randomUUID(), name: name, tasks: [] as Types.ObjectId[]} as Tag;
    user.tags.push(tag);
    await user.save();
    return mapTagToResponse(tag);
}

export async function updateTag(tagId: string, request: SetTagRequest, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId});
            const tag = user.tags.find(x => x.id === tagId);
            if (!tag) {
                throw new ResourceNotFoundException('Tag not found');
            }

            tag.name = request.name;
            await user.save({session});

            // update all tasks that this tag belongs to with the new name
            await TaskModel.updateMany(
                {'_id': {$in: tag.tasks}},
                {$set: {'tags.$[element].name': tag.name}},
                {arrayFilters: [{'element.id': tagId}]}
            ).session(session);
        });
    } finally {
        await session.endSession();
    }
}

export async function deleteTag(tagId: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            const tagToDelete = user.tags.find(x => x.id === tagId);
            user.tags = user.tags.filter(x => x.id !== tagId);
            await user.save({session});

            // remove tag from all tasks it is associated with
            await TaskModel.updateMany(
                {'_id': {$in: tagToDelete.tasks}},
                {$pull: {'tags': {'id': tagId}}}
            ).session(session);
        });
    } finally {
        await session.endSession();
    }
}

export async function createContact(name: string, email: string, phoneNumber: string, userId: string): Promise<ContactResponse> {
    const user = await UserModel.findOne({'_id': userId});
    if (user.contacts.length > maxContacts) {
        throw new BadRequestException(`Cannot have more than ${maxContacts} contacts`);
    }
    const contact = {
        id: crypto.randomUUID(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        tasks: [] as Types.ObjectId[]
    } as Contact;
    user.contacts.push(contact);
    await user.save();
    return mapContactToResponse(contact);
}

export async function updateContact(contactId: string, request: SetContactRequest, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            const contact = user.contacts.find(x => x.id === contactId);
            if (!contact) {
                throw new ResourceNotFoundException('Contact not found');
            }
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
        });
    } finally {
        await session.endSession();
    }
}

export async function deleteContact(contactId: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            const contactToDelete = user.contacts.find(x => x.id === contactId);
            user.contacts = user.contacts.filter(x => x.id !== contactId);
            await user.save({session});

            // remove contact from all tasks it is associated with
            await TaskModel.updateMany(
                {'_id': {$in: contactToDelete.tasks}},
                {$pull: {'contacts': {'id': contactId}}}
            ).session(session);
        });
    } finally {
        await session.endSession();
    }
}

export async function deleteUser(userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOneAndDelete({'_id': userId}).session(session);
            if (!user) {
                throw new ResourceNotFoundException('User not found');
            }

            // delete all tasks and rooms from user
            await TaskModel.deleteMany({'_id': {$in: user.tasks}}).session(session);
            await RoomModel.deleteMany({'_id': {$in: user.rooms}}).session(session);
            await CompletedTaskModel.deleteMany({'createdBy': userId}).session(session);

            deletePhotosBlindSend({taskIds: user.tasks.map(e => e.toHexString()), userId: userId});
            await admin.auth().deleteUser(userId); // todo can't get this to work locally
        });
    } finally {
        await session.endSession();
    }
}
