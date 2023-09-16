import {Schema, Types, model} from 'mongoose';
import {tasksCollection, usersCollection} from "./utils/collections";

export interface User {
    _id: string;
    email: string;
    tags: Tag[];
    contacts: Contact[];
    tasks: Types.ObjectId[];
    rooms: Types.ObjectId[];
}

export interface Tag {
    id: string;
    name: string;
    tasks: Types.ObjectId[];
}

export interface Contact {
    id: string;
    name: string;
    email: string;
    phoneNumber: string;
    tasks: Types.ObjectId[];
}

const ContactScheme = new Schema<Contact>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    email: {type: String},
    phoneNumber: {type: String},
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
}, {_id: false});

const TagScheme = new Schema<Tag>({
    id: {type: String, required: true},
    name: {type: String, required: true},
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
}, {_id: false});

const UserScheme = new Schema<User>({
    _id: {type: String, required: true},
    email: {type: String, required: true},
    tags: [TagScheme],
    contacts: [ContactScheme],
    tasks: [{type: Schema.Types.ObjectId, ref: tasksCollection}],
    rooms: [{type: Schema.Types.ObjectId, ref: tasksCollection}]
});

export const UserModel = model<User>(usersCollection, UserScheme);