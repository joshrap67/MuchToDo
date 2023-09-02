import express from 'express';
import bodyParser from 'body-parser';
import compression from 'compression';
import cors from 'cors';
import admin, {credential} from "firebase-admin";
import {deletePhotos} from "./photoController";
import {onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";


const app = express();
app.use(cors({credentials: true}));
app.use(compression());
app.use(bodyParser.json());
app.post('/photos', (req, res) => deletePhotos(req, res));

setGlobalOptions({maxInstances: 1});
admin.initializeApp({
    projectId: process.env.MUCHTODO_FIREBASE__PROJECTID,
    credential: credential.applicationDefault(),
    storageBucket: process.env.MUCHTODO_FIREBASE__TASKPHOTOBUCKET
});

/*
    To run locally, uncomment this code
 */
// const server = http.createServer(app);
// server.listen(9090, () => {
//     console.log(`Server running on http://localhost:9090/`);
// });

exports.photosService = onRequest(app);