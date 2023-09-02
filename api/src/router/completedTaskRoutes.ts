import express from 'express';
import {
    deleteAllCompletedTasks,
    deleteCompletedTask, deleteManyCompletedTasks,
    getAllCompletedTasksByUser,
    getCompletedTask
} from "../controllers/completedTasksController";

export default (router: express.Router) => {
    router.get('/completed-tasks', (req: express.Request<{}, {}, {}, {roomId: string}>, res) => getAllCompletedTasksByUser(req, res));
    router.get('/completed-tasks/:id', (req, res) => getCompletedTask(req, res));
    router.delete('/completed-tasks/:id', (req, res) => deleteCompletedTask(req, res));
    router.delete('/completed-tasks/all', (req, res) => deleteAllCompletedTasks(req, res));
    router.post('/completed-tasks/delete-many', (req, res) => deleteManyCompletedTasks(req, res));
};