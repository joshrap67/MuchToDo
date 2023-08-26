export interface IUpdateTaskRequest {
    name: string,
    priority: number,
    effort: number,
    roomId: string,
    estimatedCost: number,
    note: string,
    tagIds: string[],
    contactIds: string[],
    links: string[],
    photos: string[],
    completeBy: Date,
}