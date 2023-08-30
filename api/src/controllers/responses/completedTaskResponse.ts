export interface ICompletedTaskResponse {
    id: string;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    roomId: string;
    roomName: string;
    estimatedCost: number;
    note: string;
    tags: string[];
    contacts: ICompletedTaskContactResponse[];
    links: string[];
    completionDate: Date;
}

export interface ICompletedTaskContactResponse {
    name: string;
    email: string;
    phoneNumber: string;
}