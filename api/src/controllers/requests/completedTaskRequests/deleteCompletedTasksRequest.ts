import {checkSchema} from "express-validator";

export interface DeleteCompletedTasksRequest {
    taskIds: string[];
}

export const deleteCompletedTasksSchema = () => {
    return checkSchema({
        taskIds: {
            isArray: true,
        },
    }, ['body']);
}