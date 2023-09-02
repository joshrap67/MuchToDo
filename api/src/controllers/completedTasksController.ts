import express from 'express';
import * as completedTaskService from '../services/completedTaskService';
import {IDeleteCompletedTasksRequest} from "./requests/completedTaskRequests/deleteCompletedTasksRequest";

export const getAllCompletedTasksByUser = async (req: express.Request<{}, {}, {}, {
    roomId: string
}>, res: express.Response) => {
    try {
        const tasks = await completedTaskService.getCompletedTasksByUser(req.query.roomId, res.locals.firebaseId);
        return res.status(200).json(tasks);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const getCompletedTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        const task = await completedTaskService.getCompletedTaskById(req.params.id, userId);

        return res.status(200).json(task);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteCompletedTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        await completedTaskService.deleteCompletedTask(req.params.id, userId);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteAllCompletedTasks = async (_req: express.Request<{}, {}, {}>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        await completedTaskService.deleteAllCompletedTasks(userId);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteManyCompletedTasks = async (req: express.Request<{}, {}, IDeleteCompletedTasksRequest>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        await completedTaskService.deleteManyCompletedTasks(userId, req.body.taskIds);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}