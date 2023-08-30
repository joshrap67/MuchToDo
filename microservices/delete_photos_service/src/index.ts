import express from 'express';
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import router from './router';
import admin, {credential} from "firebase-admin";


const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json());
app.use('/', router());

admin.initializeApp({
    projectId: process.env.MuchToDo__ProjectId,
    credential: credential.applicationDefault(),
    storageBucket: process.env.MuchToDo__TaskPhotoBucket
});