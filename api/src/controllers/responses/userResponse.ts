export interface IUserResponse {
    id: string,
    firebaseId: string,
    email: string,
    tags: ITagResponse[],
    contacts: IContactResponse[],
    tasks: string[],
    rooms: string[]
}

export interface ITagResponse {
    id: string,
    name: string,
    tasks: string[]
}

export interface IContactResponse {
    id: string,
    name: string,
    email: string,
    phoneNumber: string,
    tasks: string[]
}