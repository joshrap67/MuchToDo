import {CompletedTask, CompletedTaskModel} from "../domain/completedTask";
import {mapCompletedTaskToResponse} from "./mappers/completedTaskMapper";
import {CompletedTaskResponse} from "../controllers/responses/completedTaskResponse";
import {ResourceNotFoundException} from "../errors/exceptions/resourceNotFoundException";

export async function getCompletedTasksByUser(roomId: string, userId: string): Promise<CompletedTaskResponse[]> {
    let completedTasks: CompletedTask[];
    if (roomId) {
        completedTasks = await CompletedTaskModel.find({'createdBy': userId, 'roomId': roomId});
    } else {
        completedTasks = await CompletedTaskModel.find({'createdBy': userId});
    }
    return completedTasks.map(x => mapCompletedTaskToResponse(x));
}

export async function getCompletedTaskById(id: string, userId: string): Promise<CompletedTaskResponse> {
    const task = await CompletedTaskModel.findOne({'_id': id, 'createdBy': userId});
    if (!task) {
        throw new ResourceNotFoundException('Completed task not found');
    }
    return mapCompletedTaskToResponse(task);
}

export async function deleteCompletedTask(id: string, userId: string): Promise<void> {
    await CompletedTaskModel.deleteOne({'_id': id, 'createdBy': userId});
}

export async function deleteAllCompletedTasks(userId: string): Promise<void> {
    await CompletedTaskModel.deleteMany({'createdBy': userId});
}

export async function deleteManyCompletedTasks(userId: string, ids: string[]): Promise<void> {
    await CompletedTaskModel.deleteMany({'_id': {$in: ids}, 'createdBy': userId});
}