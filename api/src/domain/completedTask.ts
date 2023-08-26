import {Schema, Types, model} from 'mongoose';
import {completedTasksCollection, roomsCollection} from "./utils/collections";

export interface ICompletedTask {
    _id: Types.ObjectId,
    name: string,
    createdBy: string,
    priority: number,
    effort: number,
    room: ICompletedTaskRoom,
    estimatedCost: number,
    note: string,
    tags: ICompletedTaskTag[],
    contacts: ICompletedTaskContact[],
    links: string[], // todo delete?
    photos: string[], // todo delete?
}

export interface ICompletedTaskRoom {
    id: Types.ObjectId,
    name: string
}

export interface ICompletedTaskTag {
    id: string,
    name: string
}

export interface ICompletedTaskContact {
    id: string,
    name: string,
    email: string,
    phoneNumber: string
}

const RoomSchema = new Schema<ICompletedTaskRoom>({
    id: {type: Schema.Types.ObjectId, ref: roomsCollection, required: true},
    name: {type: String, required: true},
});

const TagSchema = new Schema<ICompletedTaskTag>({
    id: {type: String, required: true},
    name: {type: String, required: true},
});

const ContactSchema = new Schema<ICompletedTaskContact>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
});

const CompletedTaskSchema = new Schema<ICompletedTask>({
    name: {type: String, required: true},
    createdBy: {type: String, required: true},
    priority: {type: Number, required: true},
    effort: {type: Number, required: true},
    room: {RoomSchema, required: true},
    estimatedCost: {type: Number},
    note: {type: String},
    tags: [TagSchema],
    contacts: [ContactSchema],
    links: [{type: String}],
    photos: [{type: String}]
});

export const CompletedTaskModel = model<ICompletedTask>(completedTasksCollection, CompletedTaskSchema);