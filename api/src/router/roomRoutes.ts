import express from 'express';
import {createRoom, deleteRoom, getAllRoomsByUser, getRoomById, updateRoom} from "../controllers/roomsController";

export default (router: express.Router) => {
    router.get('/room', (req, res) => getAllRoomsByUser(req, res));
    router.get('/room/:id', (req, res) => getRoomById(req, res));
    router.post('/room', (req, res) => createRoom(req, res));
    router.put('/room/:id', (req, res) => updateRoom(req, res));
    router.delete('/room/:id', (req, res) => deleteRoom(req, res));
};