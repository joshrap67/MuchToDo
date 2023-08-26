import express from 'express';
import http from 'http';
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import router from './router';
import mongoose from 'mongoose';
import {authenticateJWT} from "./utils/httpUtils";

const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json());
app.use(authenticateJWT);
app.use('/', router());

const MONGO_URL = process.env.MuchToDo_MongoConnectionString; // DB URI
mongoose
    .connect(MONGO_URL)
    .then(() => {
        const server = http.createServer(app);
        server.listen(8080, () => {
            console.log('Server running on http://localhost:8080/');
        });
    });