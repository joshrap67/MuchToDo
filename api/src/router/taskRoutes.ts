import express from 'express';
import {
    completeTask,
    createTask,
    deleteTask,
    getAllTasksByUser,
    getTask,
    setPhotos, setProgress,
    updateTask
} from "../controllers/taskController";

export default (router: express.Router) => {
    router.get('/tasks', (req, res) => getAllTasksByUser(req, res));
    router.get('/tasks/:id', (req, res) => getTask(req, res));
    router.post('/tasks', (req, res) => createTask(req, res));
    router.put('/tasks/:id', (req, res) => updateTask(req, res));
    router.delete('/tasks/:id', (req, res) => deleteTask(req, res));
    router.post('/tasks/:id/complete', (req, res) => completeTask(req, res));
    router.put('/tasks/:id/progress', (req, res) => setProgress(req, res));
    router.post('/tasks/:id/photos', (req, res) => setPhotos(req, res));
};