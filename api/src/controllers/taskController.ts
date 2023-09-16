import express from 'express';
import * as taskService from '../services/taskService';
import {CreateTaskRequest} from "./requests/taskRequests/createTaskRequest";
import {UpdateTaskRequest} from "./requests/taskRequests/updateTaskRequest";
import {SetPhotosRequest} from "./requests/taskRequests/setPhotosRequest";
import {CompleteTaskRequest} from "./requests/taskRequests/completeTaskRequest";
import {SetTaskProgressRequest} from "./requests/taskRequests/setTaskProgressRequest";

export const getAllTasksByUser = async (_req: express.Request, res: express.Response) => {
    const tasks = await taskService.getTasksByUser(res.locals.userId);
    return res.status(200).json(tasks);
}

export const getTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    const task = await taskService.getTaskById(req.params.id, userId);

    return res.status(200).json(task);
}

export const createTask = async (req: express.Request<{}, {}, CreateTaskRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const task = await taskService.createTask(userId, req.body);

    return res.status(201).json(task);
}

export const updateTask = async (req: express.Request<{ id: string }, {}, UpdateTaskRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const task = await taskService.updateTask(req.params.id, req.body, userId);

    return res.status(201).json(task);
}

export const setPhotos = async (req: express.Request<{ id: string }, {}, SetPhotosRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const task = await taskService.setPhotos(req.params.id, req.body, userId);

    return res.status(200).json(task);
}

export const deleteTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await taskService.deleteTask(req.params.id, userId);

    return res.status(204).send();
}

export const completeTask = async (req: express.Request<{ id: string }, {}, CompleteTaskRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const completedTask = await taskService.completeTask(req.params.id, req.body.completeDate, userId);

    return res.status(201).json(completedTask);
}

export const setProgress = async (req: express.Request<{ id: string }, {}, SetTaskProgressRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await taskService.setProgress(req.params.id, req.body.inProgress, userId);

    return res.status(204).send();
}