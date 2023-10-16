import {Schema, Types, model} from 'mongoose';
import {completedTasksCollection} from "./utils/collections";

export interface CompletedTask {
    _id: Types.ObjectId;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    roomId: string;
    roomName: string;
    cost: number;
    note: string;
    tags: string[];
    contacts: CompletedTaskContact[];
    links: string[];
    completionDate: Date;
}

export interface CompletedTaskContact {
    name: string;
    email: string;
    phoneNumber: string;
}

const ContactSchema = new Schema<CompletedTaskContact>({
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
}, {_id: false});

const CompletedTaskSchema = new Schema<CompletedTask>({
    name: {type: String, required: true},
    createdBy: {type: String, required: true},
    priority: {type: Number, required: true},
    effort: {type: Number, required: true},
    roomId: {type: String, required: true},
    roomName: {type: String, required: true},
    cost: {type: Number},
    note: {type: String},
    tags: [{type: String}],
    contacts: [ContactSchema],
    links: [{type: String}],
    completionDate: {type: Date}
});

export const CompletedTaskModel = model<CompletedTask>(completedTasksCollection, CompletedTaskSchema);