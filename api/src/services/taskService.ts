import {Task, TaskContact, TaskTag, TaskModel} from "../domain/task"
import {Contact, Tag, UserModel} from "../domain/user"
import mongoose from "mongoose";
import {RoomModel} from "../domain/room";
import {
    convertContactToTaskContact,
    convertRoomToTaskRoom,
    convertTagToTaskTag,
    convertTaskContactToCompletedTaskContact,
    convertTaskToRoomTask
} from "../domain/utils/converter";
import {CreateTaskRequest} from "../controllers/requests/taskRequests/createTaskRequest";
import {UpdateTaskRequest} from "../controllers/requests/taskRequests/updateTaskRequest";
import {TaskResponse} from "../controllers/responses/taskResponse";
import {mapTaskToResponse} from "./mappers/taskMapper";
import {SetPhotosRequest} from "../controllers/requests/taskRequests/setPhotosRequest";
import {deletePhotos, deleteTaskPhotos, getTotalUploadSize, uploadTaskPhoto} from "./photoService";
import {maxTaskCount, maxTaskPhotoCount, maxUploadBytes} from "../utils/constants";
import {CompletedTaskModel, CompletedTask} from "../domain/completedTask";
import {CompletedTaskResponse} from "../controllers/responses/completedTaskResponse";
import {mapCompletedTaskToResponse} from "./mappers/completedTaskMapper";
import {BadRequestException} from "../errors/exceptions/badRequestException";

export async function getTasksByUser(userId: string): Promise<TaskResponse[]> {
    const tasks = await TaskModel.find({'createdBy': userId});
    return tasks.map(x => mapTaskToResponse(x));
}

export async function getTaskById(id: string, userId: string): Promise<TaskResponse> {
    const task = await TaskModel.findOne({'_id': id, 'createdBy': userId});
    return mapTaskToResponse(task);
}

export async function createTask(userId: string, request: CreateTaskRequest): Promise<TaskResponse> {
    let taskResponse: TaskResponse;
    const session = await mongoose.startSession();

    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            const room = await RoomModel.findOne({'_id': request.roomId}).session(session);
            if (user.tasks.length > maxTaskCount) {
                throw new BadRequestException(`Cannot have more than ${maxTaskCount} tasks`)
            }

            const contactLookup: Record<string, Contact> = {};
            const tagLookup: Record<string, Tag> = {};
            for (const tag of user.tags) {
                tagLookup[tag.id] = tag;
            }
            for (const contact of user.contacts) {
                contactLookup[contact.id] = contact;
            }

            const taskTags: TaskTag[] = [];
            for (const tagId of request.tagIds) {
                taskTags.push(convertTagToTaskTag(tagLookup[tagId]));
            }
            const taskContacts: TaskContact[] = [];
            for (const contactId of request.contactIds) {
                taskContacts.push(convertContactToTaskContact(contactLookup[contactId]));
            }

            // create the task
            const task = new TaskModel({
                name: request.name,
                priority: request.priority,
                effort: request.effort,
                room: convertRoomToTaskRoom(room),
                createdBy: userId,
                tags: taskTags,
                contacts: taskContacts,
                links: request.links,
                note: request.note,
                estimatedCost: request.estimatedCost,
                completeBy: request.completeBy,
                inProgress: request.inProgress
            } as Task);
            await task.save({session});
            taskResponse = mapTaskToResponse(task);

            // update tags/contacts of user now that we have an id
            for (const tag of task.tags) {
                const userTag = tagLookup[tag.id];
                userTag.tasks.push(task._id);
            }
            for (const contact of task.contacts) {
                const userContact = contactLookup[contact.id];
                userContact.tasks.push(task._id);
            }
            user.tasks.push(task._id);
            await user.save({session});

            // update room with denormalized task data
            room.tasks.push(convertTaskToRoomTask(task));
            await room.save({session});
        });
    } finally {
        await session.endSession();
    }

    return taskResponse;
}

export async function updateTask(taskId: string, request: UpdateTaskRequest, userId: string): Promise<TaskResponse> {
    const session = await mongoose.startSession();
    let taskResponse;
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            const task = await TaskModel.findOne({'_id': taskId}).session(session);
            const newRoom = await RoomModel.findOne({'_id': request.roomId}).session(session);
            const oldRoom = await RoomModel.findOne({'_id': task.room.id}).session(session);
            if (!(newRoom._id.equals(oldRoom.id))) {
                // room changed, so we need to update old room to delete this task
                oldRoom.tasks = oldRoom.tasks.filter(x => !x.id.equals(task.id));
                await oldRoom.save({session});
                // update new room with denormalized task data
                newRoom.tasks.push(convertTaskToRoomTask(task));
                await newRoom.save({session});
            }

            const tagLookup: Record<string, Tag> = {};
            const contactLookup: Record<string, Contact> = {};

            for (const tag of user.tags) {
                tagLookup[tag.id] = tag;
            }
            for (const contact of user.contacts) {
                contactLookup[contact.id] = contact;
            }

            const taskTags: TaskTag[] = [];
            for (const tagId of request.tagIds) {
                taskTags.push(convertTagToTaskTag(tagLookup[tagId]));
            }
            const taskContacts: TaskContact[] = [];
            for (const contactId of request.contactIds) {
                taskContacts.push(convertContactToTaskContact(contactLookup[contactId]));
            }

            task.name = request.name;
            task.priority = request.priority;
            task.effort = request.effort;
            task.room = convertRoomToTaskRoom(newRoom);
            task.tags = taskTags;
            task.contacts = taskContacts;
            task.links = request.links;
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
                const userTag = tagLookup[tag.id];
                userTag.tasks.push(task._id);
            }
            for (const contact of task.contacts) {
                const userContact = contactLookup[contact.id];
                userContact.tasks.push(task._id);
            }
            await user.save({session});
            taskResponse = mapTaskToResponse(task);
        });
    } finally {
        await session.endSession();
    }

    return taskResponse;
}

export async function setPhotos(taskId: string, request: SetPhotosRequest, userId: string): Promise<TaskResponse> {
    const session = await mongoose.startSession();
    let response: TaskResponse;
    try {
        await session.withTransaction(async () => {
            const task = await TaskModel.findOne({'_id': taskId, 'createdBy': userId});
            if (task.photos.length + request.photosToUpload.length - request.deletedPhotos.length > maxTaskPhotoCount) {
                throw new BadRequestException(`Cannot have more than ${maxTaskPhotoCount} photos on a task.`);
            }

            if (request.deletedPhotos && request.deletedPhotos.length) {
                // remove photos that are to be deleted
                task.photos = task.photos.filter(x => !request.deletedPhotos.some(d => d === x));
                await deletePhotos(request.deletedPhotos);
            }

            const totalBytes = await getTotalUploadSize(userId);
            if (totalBytes >= maxUploadBytes) {
                throw new BadRequestException(`Cannot have more than ${maxUploadBytes} bytes uploaded`);
            }

            const uploadedPhotos: string[] = [];
            for (const photo of request.photosToUpload) {
                const fileName = await uploadTaskPhoto(photo, userId, taskId);
                uploadedPhotos.push(fileName);
            }
            task.photos.push(...uploadedPhotos);
            await task.save({session});

            response = mapTaskToResponse(task);
        });
    } finally {
        await session.endSession();
    }

    return response;
}

export async function deleteTask(taskId: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();

    try {
        await session.withTransaction(async () => await deleteAndReturnTask(session, taskId, userId));
    } finally {
        await session.endSession();
    }
}

export async function setProgress(taskId: string, inProgress: boolean, userId: string): Promise<void> {
    await TaskModel.updateOne({'_id': taskId, 'createdBy': userId}, {$set: {'inProgress': inProgress}});
}

export async function completeTask(taskId: string, completionDate: Date, userId: string): Promise<CompletedTaskResponse> {
    // completing a task is for all intents and purposes a soft delete, so perform much of the same delete steps
    const session = await mongoose.startSession();
    let completedTaskResponse;
    try {
        await session.withTransaction(async () => {
            const task = await deleteAndReturnTask(session, taskId, userId);

            const completedTask = new CompletedTaskModel({
                name: task.name,
                priority: task.priority,
                effort: task.effort,
                roomId: task.room.id.toHexString(),
                roomName: task.room.name,
                createdBy: userId,
                tags: task.tags.map(e => e.name),
                contacts: task.contacts.map((e) => convertTaskContactToCompletedTaskContact(e)),
                links: task.links,
                note: task.note,
                estimatedCost: task.estimatedCost,
                completionDate: completionDate
            } as CompletedTask);
            await completedTask.save({session});

            completedTaskResponse = mapCompletedTaskToResponse(completedTask);
        });
    } finally {
        await session.endSession();
    }
    return completedTaskResponse;
}

async function deleteAndReturnTask(session: mongoose.mongo.ClientSession, taskId: string, userId: string): Promise<Task> {
    const user = await UserModel.findOne({'_id': userId}).session(session);
    const task = await TaskModel.findOneAndDelete({'_id': taskId, 'createdBy': userId}).session(session);
    // remove task from its room
    await RoomModel.updateOne({'_id': task.room.id}, {$pull: {'tasks': {'id': taskId}}}).session(session);
    await deleteTaskPhotos(userId, [taskId]);

    for (const tag of user.tags) {
        tag.tasks = tag.tasks.filter(x => !x.equals(task.id));
    }
    for (const contact of user.contacts) {
        contact.tasks = contact.tasks.filter(x => !x.equals(task.id));
    }
    user.tasks = user.tasks.filter(x => !x.equals(task.id))
    await user.save({session});

    return task;
}