import {CompletedTaskResponse} from "../../controllers/responses/completedTaskResponse";
import {CompletedTask} from "../../domain/completedTask";

export const mapCompletedTaskToResponse = (task: CompletedTask): CompletedTaskResponse => {
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
        cost: task.cost,
        completionDate: task.completionDate,
    } as CompletedTaskResponse;
}