import {checkSchema} from "express-validator";

export interface CompleteTaskRequest {
    completeDate: Date;
    cost: number;
}

export const completeTaskSchema = () => {
    return checkSchema({
        completeDate: {
            notEmpty: {errorMessage: 'Completion date is required'},
            isISO8601: {errorMessage: 'Date not in proper format (ISO8601)'}
        },
        cost: {
            optional: {options: {values: 'falsy'}},
            isDecimal: {errorMessage: 'Cost must be a decimal'}
        },
    }, ['body']);
}