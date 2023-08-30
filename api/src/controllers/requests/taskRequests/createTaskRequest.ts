export interface ICreateTaskRequest {
    name: string;
    priority: number;
    effort: number;
    roomIds: string[];
    estimatedCost: number;
    note: string;
    tagIds: string[];
    contactIds: string[];
    links: string[];
    inProgress: boolean;
    completeBy: Date;
}