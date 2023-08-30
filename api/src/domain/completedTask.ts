import {Schema, Types, model} from 'mongoose';
import {completedTasksCollection, roomsCollection} from "./utils/collections";

export interface ICompletedTask {
    _id: Types.ObjectId;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    roomId: string;
    roomName: string;
    estimatedCost: number;
    note: string;
    tags: string[];
    contacts: ICompletedTaskContact[];
    links: string[];
    completionDate: Date;
}

export interface ICompletedTaskContact {
    name: string;
    email: string;
    phoneNumber: string;
}

const ContactSchema = new Schema<ICompletedTaskContact>({
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
}, {_id: false});

const CompletedTaskSchema = new Schema<ICompletedTask>({
    name: {type: String, required: true},
    createdBy: {type: String, required: true},
    priority: {type: Number, required: true},
    effort: {type: Number, required: true},
    roomId: {type: String, required: true},
    roomName: {type: String, required: true},
    estimatedCost: {type: Number},
    note: {type: String},
    tags: [{type: String}],
    contacts: [ContactSchema],
    links: [{type: String}],
    completionDate: {type: Date}
});

export const CompletedTaskModel = model<ICompletedTask>(completedTasksCollection, CompletedTaskSchema);