import {checkSchema} from "express-validator";
import {maxTaskPhotoCount} from "../../../utils/constants";

export interface SetPhotosRequest {
    deletedPhotos: string[];
    photosToUpload: string[]; // base64 encoded
}

export const setTaskPhotosSchema = () => {
    return checkSchema({
        photosToUpload: {
            isArray: {
                options: {max: maxTaskPhotoCount},
                errorMessage: `Cannot have more than ${maxTaskPhotoCount} photos`
            },
        },
    }, ['body']);
}