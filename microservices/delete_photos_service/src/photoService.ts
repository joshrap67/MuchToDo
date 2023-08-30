import {getStorage} from "firebase-admin/storage";

export const deletePhotos = async (userId: string, taskIds: string[]): Promise<void> => {
    for (const taskId of taskIds) {
        const [files] = await getStorage()
            .bucket()
            .getFiles({prefix: `${userId}/${taskId}/`});
        // todo test if no results found?
        for (const file of files) {
            try {
                await file.delete();
            } catch (e) {
                // todo log any errors
            }
        }
    }

}