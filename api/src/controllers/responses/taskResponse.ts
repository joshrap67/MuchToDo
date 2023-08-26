export interface ITaskResponse {
    id: string,
    name: string,
    createdBy: string,
    priority: number,
    effort: number,
    room: ITaskRoomResponse,
    estimatedCost: number,
    note: string,
    tags: ITaskTagResponse[],
    contacts: ITaskContactResponse[],
    links: string[],
    photos: string[],
    inProgress: boolean,
    completeBy: Date,
    creationDate: Date
}

export interface ITaskRoomResponse {
    id: string,
    name: string
}

export interface ITaskTagResponse {
    id: string,
    name: string
}

export interface ITaskContactResponse {
    id: string,
    name: string,
    email: string,
    phoneNumber: string
}