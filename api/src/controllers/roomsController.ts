import express from "express";
import * as roomService from "../services/roomService";
import {ISetRoomRequest} from "./requests/roomRequests/setRoomRequest";

export const getAllRoomsByUser = async (_req: express.Request, res: express.Response) => {
    try {
        const rooms = await roomService.getRoomsByUser(res.locals.firebaseId);
        return res.status(200).json(rooms);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const getRoomById = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const room = await roomService.getRoomById(req.params.id, firebaseId);

        return res.status(200).json(room);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createRoom = async (req: express.Request<{}, {}, ISetRoomRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const room = await roomService.createRoom(req.body.name, req.body.note, firebaseId);

        return res.status(200).json(room);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const updateRoom = async (req: express.Request<{ id: string }, {}, ISetRoomRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        await roomService.updateRoom(req.params.id, req.body.name, req.body.note, firebaseId);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteRoom = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        await roomService.deleteRoom(req.params.id, firebaseId);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}