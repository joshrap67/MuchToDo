import {IRoom, RoomModel} from "../domain/room";
import {UserModel} from "../domain/user";
import mongoose from "mongoose";
import {TaskModel} from "../domain/task";
import {maxRoomCount} from "../utils/constants";
import {IRoomResponse} from "../controllers/responses/roomResponse";
import {mapRoomToResponse} from "./mappers/roomMapper";

export async function getRoomsByUser(userId: string): Promise<IRoomResponse[]> {
    const rooms = await RoomModel.find({'createdBy': userId});
    return rooms ? rooms.map((r) => mapRoomToResponse(r)) : [];
}

export async function getRoomById(id: string, userId: string): Promise<IRoomResponse> {
    const room = await RoomModel.findOne({'_id': id, 'createdBy': userId});
    return mapRoomToResponse(room);
}

export async function createRoom(name: string, note: string, firebaseId: string): Promise<IRoomResponse> {
    const session = await mongoose.startSession();
    let room;
    try {
        session.startTransaction();
        const user = await UserModel.findOne({'firebaseId': firebaseId}).session(session);
        if (user.rooms.length > maxRoomCount) {
            await session.abortTransaction();
            return Promise.reject(Error('Max rooms already met'));
        }

        room = new RoomModel({
                name: name,
                note: note,
                createdBy: firebaseId,
                tasks: []
            } as IRoom
        );
        await room.save({session});
        user.rooms.push(room._id);
        await user.save({session});

        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw e;
    } finally {
        await session.endSession();
    }

    return mapRoomToResponse(room);
}

export async function updateRoom(roomId: string, name: string, note: string, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const room = await RoomModel.findOne({'_id': roomId, 'createdBy': firebaseId});
        room.name = name;
        room.note = note;
        await room.save({session});

        const taskIds = room.tasks.map(x => x.id);
        await TaskModel.updateMany({'_id': {$in: taskIds}}, {$set: {'room.name': name}}).session(session);

        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw (e);
    } finally {
        await session.endSession();
    }
}

export async function deleteRoom(roomId: string, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const room = await RoomModel.findOneAndDelete({'_id': roomId, 'createdBy': firebaseId}).session(session);

        // task cannot have null room. delete all tasks that contained this room
        const taskIds = room.tasks.map(x => x.id);
        await TaskModel.deleteMany({'_id': {$in: taskIds}}).session(session);
        // todo api call to microservice to delete photos of task
        // todo delete completed tasks? if not i need to change ui so you can still see ones of deleted rooms

        await UserModel.updateOne(
            {'firebaseId': firebaseId},
            {$pull: {'rooms': roomId, 'tasks': {$in: taskIds}}}
        ).session(session);

        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw e;
    } finally {
        await session.endSession();
    }
}
