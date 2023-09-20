import express from "express";
import * as roomService from "../services/roomService";
import {SetRoomRequest} from "./requests/roomRequests/setRoomRequest";
import {SetIsFavoriteRequest} from "./requests/roomRequests/setIsFavoriteRequest";

export const getAllRoomsByUser = async (_req: express.Request, res: express.Response) => {
    const rooms = await roomService.getRoomsByUser(res.locals.userId);
    return res.status(200).json(rooms);
}

export const getRoomById = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    const room = await roomService.getRoomById(req.params.id, userId);

    return res.status(200).json(room);
}

export const createRoom = async (req: express.Request<{}, {}, SetRoomRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const room = await roomService.createRoom(req.body.name, req.body.note, userId);

    return res.status(201).json(room);
}

export const updateRoom = async (req: express.Request<{ id: string }, {}, SetRoomRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await roomService.updateRoom(req.params.id, req.body.name, req.body.note, userId);

    return res.status(204).send();
}

export const setIsFavorite = async (req: express.Request<{ id: string }, {}, SetIsFavoriteRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await roomService.setIsFavorite(req.params.id, userId, req.body.isFavorite);

    return res.status(204).send();
}

export const deleteRoom = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await roomService.deleteRoom(req.params.id, userId);

    return res.status(204).send();
}