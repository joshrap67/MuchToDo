import express from 'express';
import {createRoom, deleteRoom, getAllRoomsByUser, getRoomById, updateRoom} from "../controllers/roomsController";

export default (router: express.Router) => {
    router.get('/rooms', (req, res) => getAllRoomsByUser(req, res));
    router.get('/rooms/:id', (req, res) => getRoomById(req, res));
    router.post('/rooms', (req, res) => createRoom(req, res));
    router.put('/rooms/:id', (req, res) => updateRoom(req, res));
    router.delete('/rooms/:id', (req, res) => deleteRoom(req, res));
};