import { ISetRoomRequest } from "../roomRequests/setRoomRequest";

export interface ICreateUserRequest {
    rooms: ISetRoomRequest[];
}