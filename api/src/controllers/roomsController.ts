import express from "express";
import * as roomService from "../services/roomService";
import {ICreateRoomRequest} from "./requests/roomRequests/createRoomRequest";
import {mapRoomToResponse} from "../services/mappers/roomMapper";
import {IUpdateRoomRequest} from "./requests/roomRequests/updateRoomRequest";

export const getAllRoomsByUser = async (_req: express.Request, res: express.Response) => {
    try {
        const rooms = await roomService.getRoomsByUser(res.locals.firebaseId);
        return res.status(200).json(rooms.map(x => mapRoomToResponse(x)));
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const getRoomById = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const room = await roomService.getRoomById(req.params.id, firebaseId);

        return res.status(200).json(mapRoomToResponse(room));
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createRoom = async (req: express.Request<{}, {}, ICreateRoomRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const room = await roomService.createRoom(req.body.name, req.body.note, firebaseId);

        return res.status(200).json(mapRoomToResponse(room));
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const updateRoom = async (req: express.Request<{ id: string }, {}, IUpdateRoomRequest>, res: express.Response) => {
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