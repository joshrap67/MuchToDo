import { ITask } from 'domain/task';
import express from 'express';
import * as taskService from 'services/taskService';
import { getUserByFirebaseId } from 'services/userService';

export const getAllTasksByUser = async (req: express.Request, res: express.Response) => {
    try {
        // todo get firebase id from auth header
        const user = await getUserByFirebaseId('');
        const tasks = await taskService.getTasksByUser(user.tasks, user.id);

        return res.status(200).json(tasks);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createTasks = async (req: express.Request<{}, {}, ITask[]>, res: express.Response) => {
    try {
        // todo get firebase id from auth header
        const user = await getUserByFirebaseId('');
        const tasks = await taskService.createTasks(user.id, req.body);

        return res.status(201).json(tasks);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}