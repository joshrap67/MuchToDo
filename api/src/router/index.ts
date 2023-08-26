import express from 'express';
import userRoutes from './userRoutes';
import roomRoutes from "./roomRoutes";
import taskRoutes from "./taskRoutes";

const router = express.Router();

export default (): express.Router => {
    userRoutes(router);
    roomRoutes(router);
    taskRoutes(router);
    return router;
};