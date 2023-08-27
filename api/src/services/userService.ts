import {ICreateRoomRequest} from "../controllers/requests/roomRequests/createRoomRequest";
import {RoomModel} from "../domain/room";
import {IContact, ITag, IUser, UserModel} from "../domain/user"
import mongoose, {Types} from "mongoose";
import {ITaskContact, ITaskTag, TaskModel} from "../domain/task";
import {defaultTags} from "../utils/defaults";
import {IUserResponse} from "../controllers/responses/userResponse";
import {mapUserToResponse} from "./mappers/userMapper";
import {ISetContactRequest} from "../controllers/requests/userRequests/setContactRequest";
import {ISetTagRequest} from "../controllers/requests/userRequests/setTagRequest";
import * as crypto from "crypto";


export async function getUserById(id: string): Promise<IUser> {
    return UserModel.findOne({'_id': id});
}

export async function getUserByFirebaseId(id: string): Promise<IUserResponse> {
    const user = await UserModel.findOne({'firebaseId': id});
    return user ? mapUserToResponse(user) : null;
}

export async function createUser(firebaseId: string, email: string, rooms: ICreateRoomRequest[] = []): Promise<IUserResponse> {
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
        user = new UserModel({
            firebaseId: firebaseId,
            email: email,
            contacts: [],
            rooms: [],
            tags: defaultTags,
            tasks: []
        });
        await user.save({session});
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
                user.rooms.push(createdRoom.id);
            }
            await user.save({session});
        }
        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
    }

    return mapUserToResponse(user);
}

export async function createTag(name: string, firebaseId: string): Promise<ITag> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const tag = {id: crypto.randomUUID(), name: name, tasks: [] as Types.ObjectId[]};
    user.tags.push(tag);
    await user.save();
    return tag;
}

export async function updateTag(tagId: string, request: ISetTagRequest, firebaseId: string): Promise<void> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const tag = user.tags.find(x => x.id === tagId);
    if (!tag) {
        throw Error('Tag not found on user.');
    }

    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        tag.name = request.name;
        await user.save({session});

        // update all tasks that this tag belongs to with the new name
        const tasks = await TaskModel.find({'_id': {$in: tag.tasks}});
        for (const task of tasks) {
            const taskTag = task.tags.find((x: ITaskTag) => x.id === tagId);
            if (taskTag) {
                taskTag.name = request.name;
                await task.save({session}); // todo faster way?
            }
        }
        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
    }
}

export async function deleteTag(tagId: string, firebaseId: string): Promise<void> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});

    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const newTags = [];
        let tagToDelete;
        for (const oldTag of user.tags) {
            if (oldTag.id === tagId) {
                tagToDelete = oldTag;
            } else {
                newTags.push(oldTag); // todo verify this doesn't mess up order. it shouldn't but just to be safe
            }
        }
        if (!tagToDelete) {
            await session.abortTransaction();
            return;
        }

        user.tags = newTags;
        await user.save({session});

        // remove tags from all tasks it is associated with
        const tasks = await TaskModel.find({'_id': {$in: tagToDelete.tasks}});
        for (const task of tasks) {
            task.tags = task.tags.filter((x: ITaskTag) => x.id !== tagId);
            await task.save({session});
        }
        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
    }
}

export async function createContact(name: string, email: string, phoneNumber: string, firebaseId: string): Promise<IContact> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const contact = {
        id: crypto.randomUUID(),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        tasks: [] as Types.ObjectId[]
    };
    user.tags.push(contact);
    await user.save();
    return contact;
}

export async function updateContact(contactId: string, request: ISetContactRequest, firebaseId: string): Promise<void> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});
    const contact = user.contacts.find(x => x.id === contactId);
    if (!contact) {
        throw Error('Contact not found on user.');
    }

    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        contact.name = request.name;
        contact.phoneNumber = request.phoneNumber;
        contact.email = request.email;
        await user.save({session});

        // update all tasks that this contact belongs to with the new fields
        const tasks = await TaskModel.find({'_id': {$in: contact.tasks}});
        for (const task of tasks) {
            const taskContact = task.contacts.find((x: ITaskContact) => x.id === contactId);
            if (taskContact) {
                taskContact.name = request.name;
                taskContact.phoneNumber = request.phoneNumber;
                taskContact.email = request.email;
                await task.save({session}); // todo faster way?
            }
        }
        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
    }
}

export async function deleteContact(contactId: string, firebaseId: string): Promise<void> {
    const user = await UserModel.findOne({'firebaseId': firebaseId});

    const session = await mongoose.startSession();
    try {
        session.startTransaction();
        const newContacts = [];
        let contactToDelete;
        for (const oldContact of user.contacts) {
            if (oldContact.id === contactId) {
                contactToDelete = oldContact;
            } else {
                newContacts.push(oldContact);
            }
        }
        if (!contactToDelete) {
            await session.abortTransaction();
            return;
        }

        user.tags = newContacts;
        await user.save({session});

        // remove tags from all tasks it is associated with
        const tasks = await TaskModel.find({'_id': {$in: contactToDelete.tasks}});
        for (const task of tasks) {
            task.tags = task.contacts.filter((x: ITaskContact) => x.id !== contactId);
            await task.save({session});
        }
        await session.commitTransaction();
    } catch (e) {
        console.log(e);
        await session.abortTransaction();
    }
}

