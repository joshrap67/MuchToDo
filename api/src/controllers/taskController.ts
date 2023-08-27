import express from 'express';
import * as taskService from '../services/taskService';
import {ICreateTaskRequest} from "./requests/taskRequests/createTaskRequest";
import {IUpdateTaskRequest} from "./requests/taskRequests/updateTaskRequest";

export const getAllTasksByUser = async (_req: express.Request, res: express.Response) => {
    try {
        const tasks = await taskService.getTasksByUser(res.locals.firebaseId);
        return res.status(200).json(tasks);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const getTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    // todo figure out how to do .net model binding validation equivalent?
    try {
        const userId = res.locals.firebaseId;
        const task = await taskService.getTaskById(req.params.id, userId);

        return res.status(200).json(task);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createTasks = async (req: express.Request<{}, {}, ICreateTaskRequest>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        const tasks = await taskService.createTasks(userId, req.body);

        return res.status(201).json(tasks);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400); // todo better responses
    }
}

export const updateTask = async (req: express.Request<{ id: string }, {}, IUpdateTaskRequest>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        const task = await taskService.updateTask(req.params.id, req.body, userId);

        return res.status(201).json(task);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteTask = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const userId = res.locals.firebaseId;
        await taskService.deleteTask(req.params.id, userId);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}