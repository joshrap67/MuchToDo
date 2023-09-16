import {checkSchema} from "express-validator";

export interface SetTaskProgressRequest {
    inProgress: boolean;
}

export const setTaskProgressSchema = () => {
    return checkSchema({
        inProgress: {
            notEmpty: {errorMessage: 'Progress is required'},
            isBoolean: {errorMessage: 'Must be a boolean value'}
        },
    }, ['body']);
}