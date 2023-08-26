import {ITask} from "../../domain/task";
import {
    ITaskContactResponse,
    ITaskResponse,
    ITaskTagResponse
} from "../../controllers/responses/taskResponse";

export const mapTaskToResponse = (task: ITask): ITaskResponse => {
    return {
        id: task._id.toHexString(),
        name: task.name,
        createdBy: task.createdBy,
        note: task.note,
        room: {id: task.room.id.toHexString(), name: task.room.name},
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
    };
}