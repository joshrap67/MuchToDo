import express from 'express';
import {deletePhotos} from "./photoController";

const router = express.Router();

export default (): express.Router => {
    router.post('/photos', (req, res) => deletePhotos(req, res));
    return router;
};