import {taskPhotoBucket} from "../utils/constants";
import * as stream from "stream";
import * as crypto from "crypto";
import {getStorage} from "firebase-admin/storage";

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

export const getTotalUploadSize = async (userId: string): Promise<number> => {
    const [files] = await getStorage()
        .bucket(taskPhotoBucket)
        .getFiles({prefix: `${userId}/`});
    let bytes = 0;
    for (const file of files) {
        bytes += +file.metadata.size; // JS is so fun
    }
    return bytes;
}

export const deleteTaskPhotos = async (userId: string, taskIds: string[]): Promise<void> => {
    for (const taskId of taskIds) {
        await getStorage()
            .bucket(taskPhotoBucket)
            .deleteFiles({prefix: `${userId}/${taskId}/`});
    }
}

export const deletePhotos = async (files: string[]): Promise<void> => {
    for (const file of files) {
        try {
            await getStorage()
                .bucket(taskPhotoBucket)
                .file(file)
                .delete();
        } catch (e) {
            console.log(`Could not delete ${file}. Error: ${e}`);
        }
    }
}