import express from 'express';
require('express-async-errors'); // todo eventually express 5 will handle this
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import router from './router/router';
import mongoose from 'mongoose';
import {authenticateJWT} from "./utils/httpUtils";
import admin, {credential} from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import {errorHandler} from "./utils/errorHandler";

const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json({limit: '50mb'}));

app.use(authenticateJWT);
app.use('/', router());
app.use(errorHandler);

setGlobalOptions({maxInstances: 1}); // todo
const MONGO_URL = process.env.MUCHTODO_MONGO__CONNECTIONSTRING; // DB URI
mongoose
    .connect(MONGO_URL)
    .then(() => {
        /*
            To run locally, uncomment this block
         */
        // const server = http.createServer(app);
        // server.listen(8080, () => {
        //     console.log(`Server running on http://localhost:8080/`);
        // });
    });

admin.initializeApp({
    projectId: process.env.MUCHTODO_FIREBASE__PROJECTID,
    credential: credential.applicationDefault()
});

exports.expressApi = onRequest(app);