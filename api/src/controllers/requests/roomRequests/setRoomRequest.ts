import {checkSchema} from "express-validator";
import {maxRoomName, maxRoomNote} from "../../../utils/constants";

export interface SetRoomRequest {
    name: string;
    note: string;
}

export const setRoomSchema = () => {
    return checkSchema({
        name: {
            trim: true,
            notEmpty: {errorMessage: 'Name cannot be empty'},
            isLength: {
                options: {max: maxRoomName},
                errorMessage: `Name cannot be more than ${maxRoomName} characters`
            }
        },
        note: {
            optional: true,
            trim: true,
            isLength: {
                options: {max: maxRoomNote},
                errorMessage: `Note cannot be more than ${maxRoomNote} characters`
            }
        },
    }, ['body']);
}