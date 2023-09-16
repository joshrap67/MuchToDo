import express from 'express';
import * as completedTaskService from '../services/completedTaskService';
import {DeleteCompletedTasksRequest} from "./requests/completedTaskRequests/deleteCompletedTasksRequest";

export const getAllCompletedTasksByUser = async (req: express.Request<{}, {}, {}, { roomId: string }>, res: express.Response) => {
    const tasks = await completedTaskService.getCompletedTasksByUser(req.query.roomId, res.locals.userId);
    return res.status(200).json(tasks);
}

export const getCompletedTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    const task = await completedTaskService.getCompletedTaskById(req.params.id, userId);

    return res.status(200).json(task);
}

export const deleteCompletedTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await completedTaskService.deleteCompletedTask(req.params.id, userId);

    return res.status(204).send();
}

export const deleteAllCompletedTasks = async (_req: express.Request<{}, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await completedTaskService.deleteAllCompletedTasks(userId);

    return res.status(204).send();
}

export const deleteManyCompletedTasks = async (req: express.Request<{}, {}, DeleteCompletedTasksRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await completedTaskService.deleteManyCompletedTasks(userId, req.body.taskIds);

    return res.status(204).send();
}