import {Task} from "../../domain/task";
import {
    TaskResponse, TaskRoomResponse,
} from "../../controllers/responses/taskResponse";

export const mapTaskToResponse = (task: Task): TaskResponse => {
    return {
        id: task._id.toHexString(),
        name: task.name,
        createdBy: task.createdBy,
        note: task.note,
        room: {id: task.room.id.toHexString(), name: task.room.name} as TaskRoomResponse,
        priority: task.priority,
        effort: task.effort,
        contacts: task.contacts,
        tags: task.tags,
        inProgress: task.inProgress,
        completeBy: task.completeBy,
        photos: [...task.photos],
        links: [...task.links],
        estimatedCost: task.estimatedCost,
        creationDate: task._id.getTimestamp(),
    } as TaskResponse;
}