export interface TaskResponse {
    id: string;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    room: TaskRoomResponse;
    estimatedCost: number;
    note: string;
    tags: TaskTagResponse[];
    contacts: TaskContactResponse[];
    links: string[];
    photos: string[];
    inProgress: boolean;
    completeBy: Date;
    creationDate: Date;
}

export interface TaskRoomResponse {
    id: string;
    name: string;
}

export interface TaskTagResponse {
    id: string;
    name: string;
}

export interface TaskContactResponse {
    id: string;
    name: string;
    email: string;
    phoneNumber: string;
}