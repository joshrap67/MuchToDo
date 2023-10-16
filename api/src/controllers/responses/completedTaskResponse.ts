export interface CompletedTaskResponse {
    id: string;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    roomId: string;
    roomName: string;
    cost: number;
    note: string;
    tags: string[];
    contacts: CompletedTaskContactResponse[];
    links: string[];
    completionDate: Date;
}

export interface CompletedTaskContactResponse {
    name: string;
    email: string;
    phoneNumber: string;
}