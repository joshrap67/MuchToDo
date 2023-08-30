import {ITask} from "../../domain/task";
import {
    ITaskContactResponse,
    ITaskResponse, ITaskRoomResponse,
    ITaskTagResponse
} from "../../controllers/responses/taskResponse";
import {ICompletedTaskResponse} from "../../controllers/responses/completedTaskResponse";
import {ICompletedTask} from "../../domain/completedTask";

export const mapCompletedTaskToResponse = (task: ICompletedTask): ICompletedTaskResponse => {
    return {
        id: task._id.toHexString(),
        name: task.name,
        createdBy: task.createdBy,
        note: task.note,
        roomName: task.roomName,
        roomId: task.roomId,
        priority: task.priority,
        effort: task.effort,
        contacts: task.contacts,
        tags: task.tags,
        links: [...task.links],
        estimatedCost: task.estimatedCost,
        completionDate: task.completionDate,
    };
}