import {CompletedTaskModel} from "../domain/completedTask";
import {mapCompletedTaskToResponse} from "./mappers/completedTaskMapper";
import {ICompletedTaskResponse} from "../controllers/responses/completedTaskResponse";


export async function getCompletedTasksByUser(roomId: string, userId: string): Promise<ICompletedTaskResponse[]> {
    let completedTasks = [];
    if (roomId) {
        completedTasks = await CompletedTaskModel.find({'createdBy': userId, 'roomId': roomId});
    } else {
        completedTasks = await CompletedTaskModel.find({'createdBy': userId});
    }
    return completedTasks.map(x => mapCompletedTaskToResponse(x));
}

export async function getCompletedTaskById(id: string, userId: string): Promise<ICompletedTaskResponse> {
    const task = await CompletedTaskModel.findOne({'_id': id, 'createdBy': userId});
    return mapCompletedTaskToResponse(task);
}


export async function deleteCompletedTask(taskId: string, userId: string): Promise<void> {
    await CompletedTaskModel.deleteOne({'_id': taskId, 'createdBy': userId});
}

export async function deleteAllCompletedTasks(userId: string): Promise<void> {
    await CompletedTaskModel.deleteMany({'createdBy': userId});
}

export async function deleteManyCompletedTasks(userId: string, taskIds: string[]): Promise<void> {
    await CompletedTaskModel.deleteMany({'_id': {$in: taskIds}, 'createdBy': userId});
}