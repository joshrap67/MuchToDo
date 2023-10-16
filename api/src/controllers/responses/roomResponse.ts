export interface RoomResponse {
    id: string;
    name: string;
    note: string;
    isFavorite: boolean;
    taskSort: number;
    taskSortDirection: number;
    createdBy: string;
    creationDate: Date;
    tasks: RoomTaskResponse[];
}

export interface RoomTaskResponse {
    id: string;
    name: string;
    estimatedCost: number;
}