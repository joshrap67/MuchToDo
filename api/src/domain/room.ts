import { Schema, Types, model } from 'mongoose';

export interface IRoom {
    id: Types.ObjectId,
    name: string,
    note: string,
    tasks: IRoomTask[]
}

export interface IRoomTask {
    id: Types.ObjectId,
    name: string,
    estimatedCost: number,
    isActive: boolean
}

const RoomScheme = new Schema<IRoom>({
    name: { type: String, required: true },
    note: { type: String },
    tasks: [
        {
            id: { type: Schema.Types.ObjectId, ref: 'task', required: true },
            name: { type: String, required: true },
            estimatedCost: { type: Number },
            isActive: { type: Boolean }
        }
    ],
});

export const RoomModel = model<IRoom>('room', RoomScheme);