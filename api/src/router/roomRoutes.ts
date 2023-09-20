import express, {NextFunction, Request, Response} from 'express';
import {
    createRoom,
    deleteRoom,
    getAllRoomsByUser,
    getRoomById,
    setIsFavorite,
    updateRoom
} from "../controllers/roomsController";
import {setRoomSchema} from "../controllers/requests/roomRequests/setRoomRequest";
import {checkValidationError} from "../utils/httpUtils";

export default (router: express.Router) => {
    router.get('/rooms', (req, res) => getAllRoomsByUser(req, res));
    router.get('/rooms/:id', (req, res) => getRoomById(req, res));
    router.post('/rooms',
        setRoomSchema(),
        (req: Request, res: Response, next: NextFunction) => checkValidationError(req, res, next),
        (req: Request, res: Response) => createRoom(req, res));
    router.put('/rooms/:id',
        setRoomSchema(),
        (req: Request, res: Response, next: NextFunction) => checkValidationError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => updateRoom(req, res));
    router.put('/rooms/:id/favorite', (req: Request<{ id: string }>, res: Response) => setIsFavorite(req, res, true));
    router.put('/rooms/:id/unfavorite', (req, res) => setIsFavorite(req, res, false));
    router.delete('/rooms/:id', (req, res) => deleteRoom(req, res));
};