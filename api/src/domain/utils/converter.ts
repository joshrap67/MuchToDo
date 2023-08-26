import {IRoom, IRoomTask} from "domain/room"
import {ITask, ITaskContact, ITaskRoom, ITaskTag} from "domain/task"
import {IContact, ITag} from "../user";

export const convertTaskToRoomTask = (task: ITask): IRoomTask => {
    return {id: task._id, name: task.name, estimatedCost: task.estimatedCost};
}

export const convertRoomToTaskRoom = (room: IRoom): ITaskRoom => {
    return {id: room._id, name: room.name};
}

export const convertTagToTaskTag = (tag: ITag): ITaskTag => {
    return {...tag};
}

export const convertContactToTaskContact = (contact: IContact): ITaskContact => {
    return {...contact};
}