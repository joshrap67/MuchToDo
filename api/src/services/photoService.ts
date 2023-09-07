import {taskPhotoBucket} from "../utils/constants";
import * as stream from "stream";
import * as crypto from "crypto";
import {getStorage} from "firebase-admin/storage";
import axios from "axios";
import * as process from "process";
import {IDeletePhotosRequest} from "../controllers/requests/taskRequests/deletePhotosRequest";

export const uploadTaskPhoto = (base64Data: string, userId: string, taskId: string): Promise<string> => {
    return new Promise((resolve, reject) => {
        const storage = getStorage();
        const taskBucket = storage.bucket(taskPhotoBucket);

        // each task should have its own directory under the user with its photos
        const fileName = `${userId}/${taskId}/${crypto.randomUUID()}.jpg`;
        const file = taskBucket.file(fileName);
        const fileStream = new stream.PassThrough();
        const bytes = Uint8Array.from(atob(base64Data), c => c.charCodeAt(0));

        fileStream.write(bytes);
        fileStream.end();
        fileStream.pipe(file.createWriteStream())
            .on('finish', () => {
                resolve(fileName);
            })
            .on('error', () => {
                reject('Error uploading photo');
            });
    });
}

export const deletePhotos = async (deletePhotosRequest: IDeletePhotosRequest): Promise<void> => {
    await axios.post(`${process.env.MUCHTODO_URLS__DELETEPHOTOS}/photos`, deletePhotosRequest);
}

export const deletePhotosBlindSend = (deletePhotosRequest: IDeletePhotosRequest): void => {
    // to be used for potentially long-running operations (like when deleting a user or room that could have hundreds of tasks with photos)
    axios.post(`${process.env.MUCHTODO_URLS__DELETEPHOTOS}/photos`, deletePhotosRequest);
}