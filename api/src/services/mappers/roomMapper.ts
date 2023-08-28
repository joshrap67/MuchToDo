import {IRoom, IRoomTask} from "../../domain/room";
import {IRoomResponse, IRoomTaskResponse} from "../../controllers/responses/roomResponse";

export const mapRoomToResponse = (room: IRoom): IRoomResponse => {
    const tasks: IRoomTaskResponse[] = [];
    for (const task of room.tasks) {
        tasks.push({id: task.id.toHexString(), name: task.name, estimatedCost: task.estimatedCost} as IRoomTaskResponse);
    }
    return {
        id: room._id.toHexString(),
        name: room.name,
        createdBy: room.createdBy,
        note: room.note,
        tasks: tasks,
        creationDate: room._id.getTimestamp()
    };
}