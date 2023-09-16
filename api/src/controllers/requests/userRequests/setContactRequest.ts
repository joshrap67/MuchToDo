import {checkSchema} from "express-validator";
import {maxContactName, maxEmailLength, maxPhoneLength} from "../../../utils/constants";

export interface SetContactRequest {
    name: string;
    email: string;
    phoneNumber: string;
}

export const setContactSchema = () => {
    return checkSchema({
        name: {
            trim: true,
            notEmpty: {errorMessage: 'Name cannot be empty'},
            isLength: {
                options: {max: maxContactName},
                errorMessage: `Name cannot be more than ${maxContactName} characters`
            }
        },
        email: {
            optional: true,
            trim: true,
            isLength: {
                options: {max: maxEmailLength},
                errorMessage: `Email cannot be more than ${maxEmailLength} characters`
            }
        },
        phoneNumber: {
            optional: true,
            trim: true,
            isLength: {
                options: {max: maxPhoneLength},
                errorMessage: `Phone number cannot be more than ${maxPhoneLength} characters`
            }
        }
    }, ['body']);
}