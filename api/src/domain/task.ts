import { Schema, Types, model } from 'mongoose';

export interface ITask {
    id: Types.ObjectId,
    name: string,
    createdBy: Types.ObjectId,
    priority: number,
    effort: number,
    room: ITaskRoom,
    estimatedCost: number,
    note: string,
    tags: ITaskTag[],
    contacts: ITaskContact[],
    links: string[],
    photos: string[],
    isCompleted: boolean,
    inProgress: boolean,
    completeBy: Date,
    creationDate: Date
}

export interface ITaskRoom {
    id: Types.ObjectId,
    name: string
}

export interface ITaskTag {
    id: string,
    name: string
}

export interface ITaskContact {
    id: string,
    name: string,
    email: string,
    phoneNumber: string
}

const TaskScheme = new Schema<ITask>({
    name: { type: String, required: true },
    createdBy: { type: Schema.Types.ObjectId, ref: 'user', required: true },
    priority: { type: Number, required: true },
    effort: { type: Number, required: true },
    room: {
        type: {
            id: { type: Schema.Types.ObjectId, ref: 'room', required: true },
            name: { type: String, required: true },
        },
        required: true
    },
    estimatedCost: { type: Number },
    note: { type: String },
    tags: [
        {
            type: {
                id: { type: String, required: true },
                name: { type: String, required: true }
            }
        }
    ],
    contacts: [
        {
            type: {
                id: { type: String, required: true },
                name: { type: String, required: true },
                email: { type: String },
                phoneNumber: { type: String },
            }
        }
    ],
    links: [
        { type: String }
    ],
    photos: [
        { type: String }
    ],
    isCompleted: { type: Boolean },
    inProgress: { type: Boolean },
    creationDate: { type: Date, default: Date.now },
    completeBy: { type: Date }
});

export const TaskModel = model<ITask>('task', TaskScheme);