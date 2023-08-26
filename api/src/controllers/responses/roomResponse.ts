export interface IRoomResponse {
    id: string,
    name: string,
    note: string,
    createdBy: string,
    creationDate: Date,
    tasks: IRoomTaskResponse[]
}

export interface IRoomTaskResponse {
    id: string,
    name: string,
    estimatedCost: number
}