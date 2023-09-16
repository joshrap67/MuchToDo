import express, {NextFunction, Request, Response} from 'express';
import {
    completeTask,
    createTask,
    deleteTask,
    getAllTasksByUser,
    getTask,
    setPhotos, setProgress,
    updateTask
} from "../controllers/taskController";
import {checkError} from "../utils/httpUtils";
import {completeTaskSchema} from "../controllers/requests/taskRequests/completeTaskRequest";
import {createTaskSchema} from "../controllers/requests/taskRequests/createTaskRequest";
import {updateTaskSchema} from "../controllers/requests/taskRequests/updateTaskRequest";
import {setTaskProgressSchema} from "../controllers/requests/taskRequests/setTaskProgressRequest";
import {setTaskPhotosSchema} from "../controllers/requests/taskRequests/setPhotosRequest";

export default (router: express.Router) => {
    router.get('/tasks', (req, res) => getAllTasksByUser(req, res));
    router.get('/tasks/:id', (req, res) => getTask(req, res));
    router.post('/tasks',
        createTaskSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => createTask(req, res));
    router.put('/tasks/:id',
        updateTaskSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => updateTask(req, res));
    router.delete('/tasks/:id', (req, res) => deleteTask(req, res));
    router.post('/tasks/:id/complete',
        completeTaskSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => completeTask(req, res));
    router.put('/tasks/:id/progress',
        setTaskProgressSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => setProgress(req, res));
    router.post('/tasks/:id/photos',
        setTaskPhotosSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => setPhotos(req, res));
};