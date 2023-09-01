import express from 'express';
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import admin, {credential} from "firebase-admin";
import http from "http";
import {deletePhotos} from "./photoController";


const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json());
app.post('/photos', (req, res) => deletePhotos(req, res));

admin.initializeApp({
    projectId: process.env.MuchToDo_Firebase__ProjectId,
    credential: credential.applicationDefault(),
    storageBucket: process.env.MuchToDo__TaskPhotoBucket
});

const server = http.createServer(app);
const port = process.env.MuchToDo_Microservice__DeletePhotosPort || 9090;
server.listen(port, () => {
    console.log(`Server running on http://localhost:${port}/`);
});