import express from 'express';
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import router from './router/router';
import mongoose from 'mongoose';
import {authenticateJWT} from "./utils/httpUtils";
import admin, {credential} from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";

const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json({limit: '50mb'}));

app.use(authenticateJWT);
app.use('/', router());

setGlobalOptions({ maxInstances: 1 }); // todo
const MONGO_URL = process.env.MUCHTODO_MONGO__CONNECTIONSTRING; // DB URI
mongoose
    .connect(MONGO_URL)
    .then(() => {
        // const server = http.createServer(app);
        // const port = process.env.MuchToDo_Api__Port || 8080
        // server.listen(port, () => {
        //     console.log(`Server running on http://localhost:${port}/`);
        // });
    });

admin.initializeApp({
    projectId: process.env.MUCHTODO_FIREBASE__PROJECTID,
    credential: credential.applicationDefault()
});

exports.expressApi = onRequest(app);