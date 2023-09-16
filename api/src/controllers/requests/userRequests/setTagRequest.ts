import {checkSchema} from "express-validator";
import {maxTagName} from "../../../utils/constants";

export interface SetTagRequest {
    name: string;
}

export const setTagSchema = () => {
    return checkSchema({
        name: {
            trim: true,
            notEmpty: {errorMessage: 'Name cannot be empty'},
            isLength: {
                options: {max: maxTagName},
                errorMessage: `Name cannot be more than ${maxTagName} characters`
            }
        }
    }, ['body']);
}