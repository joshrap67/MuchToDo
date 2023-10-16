import {checkSchema} from "express-validator";

export interface SetRoomTaskSortRequest {
    taskSort: number;
    taskSortDirection: number;
}

export const setRoomTaskSortSchema = () => {
    return checkSchema({
        taskSort: {
            isInt: {errorMessage: 'Task sort must be an integer'},
            notEmpty: {errorMessage: 'Task sort cannot be empty'},
        },
        taskSortDirection: {
            isInt: {errorMessage: 'Task sort direction must be an integer'},
            notEmpty: {errorMessage: 'Task sort direction cannot be empty'},
        },
    }, ['body']);
}