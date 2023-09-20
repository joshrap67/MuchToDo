import {checkSchema} from "express-validator";

export interface SetIsFavoriteRequest {
    isFavorite: boolean;
}

export const setIsFavoriteSchema = () => {
    return checkSchema({
        isFavorite: {
            notEmpty: {errorMessage: 'Favorite value is required'},
            isBoolean: {errorMessage: 'Must be a boolean value'}
        },
    }, ['body']);
}