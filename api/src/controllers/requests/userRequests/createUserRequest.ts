import { ICreateRoomRequest } from "../roomRequests/createRoomRequest";

export interface ICreateUserRequest {
    rooms: ICreateRoomRequest[];
}