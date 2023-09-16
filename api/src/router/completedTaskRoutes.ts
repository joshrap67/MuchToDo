import express, {NextFunction, Request, Response} from 'express';
import {
    deleteAllCompletedTasks,
    deleteCompletedTask, deleteManyCompletedTasks,
    getAllCompletedTasksByUser,
    getCompletedTask
} from "../controllers/completedTasksController";
import {deleteCompletedTasksSchema} from "../controllers/requests/completedTaskRequests/deleteCompletedTasksRequest";
import {checkError} from "../utils/httpUtils";

export default (router: express.Router) => {
    router.get('/completed-tasks', (req: express.Request<{}, {}, {}, {roomId: string}>, res) => getAllCompletedTasksByUser(req, res));
    router.get('/completed-tasks/:id', (req, res) => getCompletedTask(req, res));
    router.delete('/completed-tasks/:id', (req, res) => deleteCompletedTask(req, res));
    router.delete('/completed-tasks/all', (req, res) => deleteAllCompletedTasks(req, res));
    router.post('/completed-tasks/delete-many',
        deleteCompletedTasksSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => deleteManyCompletedTasks(req, res));
};