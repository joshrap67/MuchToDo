import express, {NextFunction, Request, Response} from 'express';
import {createRoom, deleteRoom, getAllRoomsByUser, getRoomById, updateRoom} from "../controllers/roomsController";
import {setRoomSchema} from "../controllers/requests/roomRequests/setRoomRequest";
import {checkError} from "../utils/httpUtils";

export default (router: express.Router) => {
    router.get('/rooms', (req, res) => getAllRoomsByUser(req, res));
    router.get('/rooms/:id', (req, res) => getRoomById(req, res));
    router.post('/rooms',
        setRoomSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => createRoom(req, res));
    router.put('/rooms/:id',
        setRoomSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => updateRoom(req, res));
    router.delete('/rooms/:id', (req, res) => deleteRoom(req, res));
};