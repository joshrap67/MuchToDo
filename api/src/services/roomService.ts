import {IRoom, RoomModel} from "../domain/room";
import {UserModel} from "../domain/user";
import mongoose from "mongoose";
import {TaskModel} from "../domain/task";
import {maxRoomCount} from "../utils/constants";

export async function getRoomsByUser(userId: string): Promise<IRoom[]> {
    return RoomModel.find({'createdBy': {userId}});
}

export async function getRoomById(id: string, userId: string): Promise<IRoom> {
    return RoomModel.findOne({'_id': id, 'createdBy': userId});
}

export async function createRoom(name: string, note: string, firebaseId: string): Promise<IRoom> {
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
        user.rooms.push(room.id);
        await user.save({session});

        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw e;
    } finally {
        await session.endSession();
    }

    return room;
}

export async function updateRoom(roomId: string, name: string, note: string, firebaseId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        session.startTransaction();

        const room = await RoomModel.findById(roomId);
        room.name = name;
        room.note = note;
        await room.save({session});

        const tasks = await TaskModel.find({'room.id': roomId, 'createdBy': firebaseId}).session(session);
        for (const task of tasks) {
            task.room.name = name;
            await task.save({session});
        }

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

        const user = await UserModel.findOne({'firebaseId': firebaseId}).session(session);
        const roomDeleted = await RoomModel.deleteOne({'_id': roomId, 'createdBy': firebaseId}).session(session);
        if (roomDeleted.deletedCount !== 1) {
            await session.abortTransaction();
            return;
        }
        // task cannot have null room. delete all tasks that contained this room
        await TaskModel.deleteMany({'room.id': roomId, 'createdBy': firebaseId}).session(session);
        // remove room from user
        user.rooms = user.rooms.filter(x => !x.equals(roomId));
        await session.commitTransaction();
    } catch (e) {
        await session.abortTransaction();
        throw e;

    } finally {
        await session.endSession();
    }
}
