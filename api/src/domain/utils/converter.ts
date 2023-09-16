import {Room, RoomTask} from "domain/room"
import {Task, TaskContact, TaskRoom, TaskTag} from "domain/task"
import {Contact, Tag} from "../user";
import {CompletedTaskContact} from "../completedTask";

export const convertTaskToRoomTask = (task: Task): RoomTask => {
    return {id: task._id, name: task.name, estimatedCost: task.estimatedCost} as RoomTask;
}

export const convertRoomToTaskRoom = (room: Room): TaskRoom => {
    return {id: room._id, name: room.name} as TaskRoom;
}

export const convertTagToTaskTag = (tag: Tag): TaskTag => {
    return {id: tag.id, name: tag.name} as TaskTag;
}

export const convertContactToTaskContact = (contact: Contact): TaskContact => {
    return {id: contact.id, name: contact.name, email: contact.email, phoneNumber: contact.phoneNumber} as TaskContact;
}

export const convertTaskContactToCompletedTaskContact = (contact: TaskContact): CompletedTaskContact => {
    return {name: contact.name, email: contact.email, phoneNumber: contact.phoneNumber} as CompletedTaskContact;
}