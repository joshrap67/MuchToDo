import express from 'express';
import userRoutes from './userRoutes';
import roomRoutes from "./roomRoutes";
import taskRoutes from "./taskRoutes";
import completedTaskRoutes from "./completedTaskRoutes";

const router = express.Router();

export default (): express.Router => {
    userRoutes(router);
    roomRoutes(router);
    taskRoutes(router);
    completedTaskRoutes(router);
    return router;
};