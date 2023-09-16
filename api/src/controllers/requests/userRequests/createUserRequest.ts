import {SetRoomRequest} from "../roomRequests/setRoomRequest";
import {checkSchema} from "express-validator";
import {maxRoomCount} from "../../../utils/constants";

export interface CreateUserRequest {
    rooms: SetRoomRequest[];
}

export const createUserSchema = () => {
    return checkSchema({
        rooms: {
            isArray: {options: {max: maxRoomCount}, errorMessage: `Cannot have more than ${maxRoomCount} rooms`},
        }
    }, ['body']);
}