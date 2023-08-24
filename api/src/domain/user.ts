import { Schema, Types, model } from 'mongoose';

export interface IUser {
    id: Types.ObjectId,
    firebaseId: String,
    email: string,
    tags: ITag[],
    contacts: IContact[],
    tasks: Types.ObjectId[],
    rooms: Types.ObjectId[]
}

export interface ITag {
    id: Types.ObjectId,
    name: string,
    tasks: Types.ObjectId[]
}

export interface IContact {
    id: Types.ObjectId,
    name: string,
    email: string,
    phoneNumber: string,
    tasks: Types.ObjectId[]
}

const UserScheme = new Schema<IUser>({
    email: { type: String, required: true },
    firebaseId: { type: String, required: true },
    tags: [
        {
            id: { type: Schema.Types.ObjectId, required: true },
            name: { type: String, required: true },
            tasks: [{ type: Schema.Types.ObjectId, ref: 'task' }]
        }
    ],
    contacts: [
        {
            id: { type: Schema.Types.ObjectId, required: true },
            name: { type: String, required: true },
            email: { type: String },
            phoneNumber: { type: String },
            tasks: [{ type: Schema.Types.ObjectId, ref: 'task' }]
        }
    ],
    tasks: [
        { type: Schema.Types.ObjectId, ref: 'task' }
    ],
    rooms: [
        { type: Schema.Types.ObjectId, ref: 'room' }
    ]
});

export const UserModel = model<IUser>('user', UserScheme);