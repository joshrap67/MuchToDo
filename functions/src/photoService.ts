import {getStorage} from "firebase-admin/storage";

const taskPhotoBucket = process.env.MUCHTODO_FIREBASE__TASKPHOTOBUCKET;

export const deletePhotos = async (userId: string, taskIds: string[]): Promise<void> => {
    for (const taskId of taskIds) {
        const [files] = await getStorage()
            .bucket(taskPhotoBucket)
            .getFiles({prefix: `${userId}/${taskId}/`});
        for (const file of files) {
            try {
                await file.delete();
            } catch (e) {
                // todo log any errors
            }
        }
    }

}