import {Room, RoomModel} from "../domain/room";
import {UserModel} from "../domain/user";
import mongoose from "mongoose";
import {TaskModel} from "../domain/task";
import {maxRoomCount} from "../utils/constants";
import {RoomResponse} from "../controllers/responses/roomResponse";
import {mapRoomToResponse} from "./mappers/roomMapper";
import {ResourceNotFoundException} from "../errors/exceptions/resourceNotFoundException";
import {BadRequestException} from "../errors/exceptions/badRequestException";
import {deleteTaskPhotos} from "./photoService";

export async function getRoomsByUser(userId: string): Promise<RoomResponse[]> {
    const rooms = await RoomModel.find({'createdBy': userId});
    return rooms ? rooms.map((r) => mapRoomToResponse(r)) : [];
}

export async function getRoomById(id: string, userId: string): Promise<RoomResponse> {
    const room = await RoomModel.findOne({'_id': id, 'createdBy': userId});
    return mapRoomToResponse(room);
}

export async function createRoom(name: string, note: string, userId: string): Promise<RoomResponse> {
    const session = await mongoose.startSession();
    let roomResponse;
    try {
        await session.withTransaction(async () => {
            const user = await UserModel.findOne({'_id': userId}).session(session);
            if (user.rooms.length > maxRoomCount) {
                throw new BadRequestException(`Max rooms already met (${maxRoomCount})`);
            }

            const room = new RoomModel({
                    name: name,
                    note: note,
                    createdBy: userId,
                    isFavorite: false,
                    tasks: []
                } as Room
            );
            await room.save({session});
            user.rooms.push(room._id);
            await user.save({session});
            roomResponse = mapRoomToResponse(room);
        });
    } finally {
        await session.endSession();
    }

    return roomResponse;
}

export async function updateRoom(roomId: string, name: string, note: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const room = await RoomModel.findOne({'_id': roomId, 'createdBy': userId});
            if (!room) {
                throw new ResourceNotFoundException('Room not found');
            }
            room.name = name;
            room.note = note;
            await room.save({session});

            const taskIds = room.tasks.map(x => x.id);
            await TaskModel.updateMany({'_id': {$in: taskIds}}, {$set: {'room.name': name}}).session(session);
        });
    } finally {
        await session.endSession();
    }
}

export async function setIsFavorite(roomId: string, userId: string, isFavorite: boolean): Promise<void> {
    await RoomModel.updateOne({'_id': roomId, 'createdBy': userId}, {$set: {'isFavorite': isFavorite}});
}

export async function setTaskSort(roomId: string, userId: string, taskSort: number, taskSortDirection: number): Promise<void> {
    await RoomModel.updateOne({'_id': roomId, 'createdBy': userId}, {$set: {'taskSort': taskSort, 'taskSortDirection': taskSortDirection}});
}

export async function deleteRoom(roomId: string, userId: string): Promise<void> {
    const session = await mongoose.startSession();
    try {
        await session.withTransaction(async () => {
            const room = await RoomModel.findOneAndDelete({'_id': roomId, 'createdBy': userId}).session(session);
            const user = await UserModel.findOne({'_id': userId}).session(session);

            // task cannot have null room. delete all tasks that contained this room
            const taskIds = room.tasks.map(x => x.id);
            await TaskModel.deleteMany({'_id': {$in: taskIds}}).session(session);
            deleteTaskPhotos(userId, taskIds.map(e => e.toHexString())); // ignore promise since this could take a while

            user.rooms = user.rooms.filter(x => x.toHexString() !== roomId);
            // remove deleted tasks from tags/contacts
            for (const tag of user.tags) {
                tag.tasks = tag.tasks.filter(t => !taskIds.some(deletedTaskId => deletedTaskId.equals(t)));
            }
            for (const contact of user.contacts) {
                contact.tasks = contact.tasks.filter(t => !taskIds.some(deletedTaskId => deletedTaskId.equals(t)));
            }
            await user.save({session});
        });
    } finally {
        await session.endSession();
    }
}
