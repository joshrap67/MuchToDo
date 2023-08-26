import express from 'express';
import {createTasks, deleteTask, getAllTasksByUser, getTask, updateTask} from "../controllers/taskController";

export default (router: express.Router) => {
    router.get('/tasks', (req, res) => getAllTasksByUser(req, res));
    router.get('/tasks/:id', (req, res) => getTask(req, res));
    router.post('/tasks', (req, res) => createTasks(req, res));
    router.put('/tasks/:id', (req, res) => updateTask(req, res));
    router.delete('/tasks/:id', (req, res) => deleteTask(req, res));
};