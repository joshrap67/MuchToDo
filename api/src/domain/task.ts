import mongoose, {Schema, Types, model} from 'mongoose';
import {roomsCollection, tasksCollection} from "./utils/collections";

export interface ITask {
    _id: Types.ObjectId;
    name: string;
    createdBy: string;
    priority: number;
    effort: number;
    room: ITaskRoom;
    estimatedCost: number;
    note: string;
    tags: ITaskTag[];
    contacts: ITaskContact[];
    links: string[];
    photos: string[];
    inProgress: boolean;
    completeBy: Date;
}

export interface ITaskRoom {
    id: Types.ObjectId;
    name: string;
}

export interface ITaskTag {
    id: string;
    name: string;
}

export interface ITaskContact {
    id: string;
    name: string;
    email: string;
    phoneNumber: string;
}

const RoomSchema = new Schema<ITaskRoom>({
    id: {type: Schema.Types.ObjectId, ref: roomsCollection, required: true},
    name: {type: String, required: true},
}, {_id: false});

const TagSchema = new Schema<ITaskTag>({
    id: {type: String, required: true},
    name: {type: String, required: true},
}, {_id: false});

const ContactSchema = new Schema<ITaskContact>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
}, {_id: false});

const TaskSchema = new Schema<ITask>({
    name: {type: String, required: true},
    createdBy: {type: String, required: true, index: true},
    priority: {type: Number, required: true},
    effort: {type: Number, required: true},
    room: RoomSchema,
    estimatedCost: {type: Number},
    note: {type: String},
    tags: [TagSchema],
    contacts: [ContactSchema],
    links: [{type: String}],
    photos: [{type: String}],
    inProgress: {type: Boolean},
    completeBy: {type: Date}
});

export const TaskModel = model<ITask>(tasksCollection, TaskSchema);