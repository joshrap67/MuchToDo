import {ITask, ITaskContact, ITaskTag, TaskModel} from "../domain/task"
import {IContact, ITag, UserModel} from "../domain/user"
import mongoose from "mongoose";
import {IRoom, RoomModel} from "../domain/room";
import {
    convertContactToTaskContact,
    convertRoomToTaskRoom,
    convertTagToTaskTag,
    convertTaskToRoomTask
} from "../domain/utils/converter";
import {ICreateTaskRequest} from "../controllers/requests/taskRequests/createTaskRequest";
import {IUpdateTaskRequest} from "../controllers/requests/taskRequests/updateTaskRequest";
import {ITaskResponse} from "../controllers/responses/taskResponse";
import {mapTaskToResponse} from "./mappers/taskMapper";

export async function getTasksByUser(userId: string): Promise<ITaskResponse[]> {
    const tasks = await TaskModel.find({'createdBy': userId});
    return tasks.map(x => mapTaskToResponse(x));
}

export async function getTaskById(id: string, userId: string): Promise<ITaskResponse> {
    const task = await TaskModel.findOne({'_id': id, 'createdBy': userId});
    return mapTaskToResponse(task);
}

export async function createTasks(userId: string, request: ICreateTaskRequest): Promise<ITaskResponse[]> {
    const createdTasks: ITask[] = [];
    const session = await mongoose.startSession();

    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': userId}).session(session);
        const rooms = await RoomModel.find({'_id': {$in: request.roomIds}}).session(session);

        const tagIdToTag: Record<string, ITag> = {};
        const contactIdToContact: Record<string, IContact> = {};
        const roomIdToRoom: Record<string, IRoom> = {};
        const roomIdToTask: Record<string, ITask> = {};

        for (const room of rooms) {
            roomIdToRoom[room.id] = room;
        }
        for (const tag of user.tags) {
            tagIdToTag[tag.id] = tag;
        }
        for (const contact of user.contacts) {
            contactIdToContact[contact.id] = contact;
        }

        const taskTags: ITaskTag[] = [];
        for (const tagId of request.tagIds) {
            taskTags.push(convertTagToTaskTag(tagIdToTag[tagId]));
        }
        const taskContacts: ITaskContact[] = [];
        for (const contactId of request.contactIds) {
            taskContacts.push(convertContactToTaskContact(contactIdToContact[contactId]));
        }

        // create the tasks
        for (const roomId of request.roomIds) {
            const task = new TaskModel({
                name: request.name,
                priority: request.priority,
                effort: request.effort,
                room: convertRoomToTaskRoom(roomIdToRoom[roomId]),
                createdBy: userId,
                tags: taskTags,
                contacts: taskContacts,
                links: request.links,
                photos: request.photos,
                note: request.note,
                estimatedCost: request.estimatedCost,
                completeBy: request.completeBy,
                inProgress: request.inProgress
            });
            await task.save({session});
            roomIdToTask[roomId] = task;
            createdTasks.push(task);

            // update tags/contacts of user now that we have an id
            for (const tag of task.tags) {
                const userTag = tagIdToTag[tag.id];
                userTag.tasks.push(task._id);
            }
            for (const contact of task.contacts) {
                const userContact = contactIdToContact[contact.id];
                userContact.tasks.push(task._id);
            }
            user.tasks.push(task._id);
            await user.save({session});
        }

        // update rooms with denormalized task data
        for (const room of rooms) {
            const task = roomIdToTask[room.id];
            room.tasks.push(convertTaskToRoomTask(task));
            await room.save({session});
        }
        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw (e);
    } finally {
        await session.endSession();
    }

    return createdTasks.map(x => mapTaskToResponse(x));
}

export async function updateTask(taskId: string, request: IUpdateTaskRequest, userId: string): Promise<ITaskResponse> {
    const session = await mongoose.startSession();
    let taskResponse;
    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': userId}).session(session);
        const task = await TaskModel.findOne({'_id': taskId}).session(session);
        const newRoom = await RoomModel.findOne({'_id': request.roomId}).session(session);
        const oldRoom = await RoomModel.findOne({'_id': task.room.id}).session(session);
        if (!(newRoom._id.equals(oldRoom.id))) {
            // room changed, so we need to update old room to delete this task
            oldRoom.tasks = oldRoom.tasks.filter(x => !x.id.equals(task.id));
            await oldRoom.save({session});
        }

        const tagIdToTag: Record<string, ITag> = {};
        const contactIdToContact: Record<string, IContact> = {};

        for (const tag of user.tags) {
            tagIdToTag[tag.id] = tag;
        }
        for (const contact of user.contacts) {
            contactIdToContact[contact.id] = contact;
        }

        const taskTags: ITaskTag[] = [];
        for (const tagId of request.tagIds) {
            taskTags.push(convertTagToTaskTag(tagIdToTag[tagId]));
        }
        const taskContacts: ITaskContact[] = [];
        for (const contactId of request.contactIds) {
            taskContacts.push(convertContactToTaskContact(contactIdToContact[contactId]));
        }

        // todo validation of fields
        task.name = request.name;
        task.priority = request.priority;
        task.effort = request.effort;
        task.room = convertRoomToTaskRoom(newRoom);
        task.tags = taskTags;
        task.contacts = taskContacts;
        task.links = request.links;
        task.photos = request.photos;
        task.note = request.note;
        task.estimatedCost = request.estimatedCost;
        task.completeBy = request.completeBy;
        await task.save({session});

        // update tags/contacts of user
        // it's easier to just remove this task for every contact/tag and then add it back if needed
        for (const contact of user.contacts) {
            contact.tasks = contact.tasks.filter(t => !t.equals(task._id));
        }
        for (const tag of user.tags) {
            tag.tasks = tag.tasks.filter(t => !t.equals(task._id));
        }

        for (const tag of task.tags) {
            const userTag = tagIdToTag[tag.id];
            userTag.tasks.push(task._id);
        }
        for (const contact of task.contacts) {
            const userContact = contactIdToContact[contact.id];
            userContact.tasks.push(task._id);
        }
        await user.save({session});

        // update room with denormalized task data
        newRoom.tasks.push(convertTaskToRoomTask(task));
        await newRoom.save({session});
        await session.commitTransaction();

        taskResponse = mapTaskToResponse(task);
    } catch (e) {
        await session.abortTransaction();
        throw (e);
    } finally {
        await session.endSession();
    }

    return taskResponse;
}

export async function deleteTask(taskId: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();

    try {
        session.startTransaction();

        const user = await UserModel.findOne({'firebaseId': userId}).session(session);
        const task = await TaskModel.findOneAndDelete({'_id': taskId, 'createdBy': userId}).session(session);
        // remove task from its room
        await RoomModel.updateOne({'_id': task.room.id}, {$pull: {'tasks': {'id': taskId}}}).session(session);

        for (const tag of user.tags) {
            tag.tasks = tag.tasks.filter(x => !x.equals(task.id));
        }
        for (const contact of user.contacts) {
            contact.tasks = contact.tasks.filter(x => !x.equals(task.id));
        }
        user.tasks = user.tasks.filter(x => !x.equals(task.id))
        await user.save({session});

        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw (e);
    } finally {
        await session.endSession();
    }
}