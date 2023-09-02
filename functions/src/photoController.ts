import express from 'express';
import * as photoService from './photoService';
import {IDeletePhotosRequest} from "./deletePhotosRequest";


export const deletePhotos = async (req: express.Request<{}, {}, IDeletePhotosRequest>, res: express.Response) => {
    try {
         await photoService.deletePhotos(req.body.firebaseId, req.body.taskIds);

        return res.status(204).send();
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}