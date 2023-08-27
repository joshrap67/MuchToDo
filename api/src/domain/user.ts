import {Schema, Types, model} from 'mongoose';
import {tasksCollection, usersCollection} from "./utils/collections";

export interface IUser {
    _id: Types.ObjectId; // I'm not actually using this, mongo makes it a pain to set your own id so treating firebaseId as primary key
    firebaseId: string;
    email: string;
    tags: ITag[];
    contacts: IContact[];
    tasks: Types.ObjectId[];
    rooms: Types.ObjectId[];
}

export interface ITag {
    id: string;
    name: string;
    tasks: Types.ObjectId[];
}

export interface IContact {
    id: string;
    name: string;
    email: string;
    phoneNumber: string;
    tasks: Types.ObjectId[];
}

const ContactScheme = new Schema<IContact>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
}, {_id: false});

const TagScheme = new Schema<ITag>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
}, {_id: false});

const UserScheme = new Schema<IUser>({
    firebaseId: {type: String, required: true, index: true},
    email: {type: String, required: true},
    tags: [TagScheme],
    contacts: [ContactScheme],
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}],
    rooms: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
});

export const UserModel = model<IUser>(usersCollection, UserScheme);