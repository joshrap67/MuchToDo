import {Room} from "../../domain/room";
import {RoomResponse, RoomTaskResponse} from "../../controllers/responses/roomResponse";

export const mapRoomToResponse = (room: Room): RoomResponse => {
    const tasks: RoomTaskResponse[] = [];
    for (const task of room.tasks) {
        tasks.push({id: task.id.toHexString(), name: task.name, estimatedCost: task.estimatedCost} as RoomTaskResponse);
    }
    return {
        id: room._id.toHexString(),
        name: room.name,
        createdBy: room.createdBy,
        note: room.note,
        isFavorite: room.isFavorite,
        taskSort: room.taskSort,
        taskSortDirection: room.taskSortDirection,
        tasks: tasks,
        creationDate: room._id.getTimestamp()
    } as RoomResponse;
}