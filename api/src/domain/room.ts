import {Schema, Types, model} from 'mongoose';
import {roomsCollection, tasksCollection} from "./utils/collections";

export interface IRoom {
    _id: Types.ObjectId;
    name: string;
    note: string;
    createdBy: string;
    tasks: IRoomTask[];
}

export interface IRoomTask {
    id: Types.ObjectId;
    name: string;
    estimatedCost: number;
}

const TaskSchema = new Schema<IRoomTask>({
    id: {type: Schema.Types.ObjectId, ref: tasksCollection, required: true},
    name: {type: String},
    estimatedCost: {type: Number},
}, {_id: false});

const RoomSchema = new Schema<IRoom>({
    name: {type: String, required: true},
    note: {type: String},
    createdBy: {type: String, required: true, index: true},
    tasks: [TaskSchema],
});

export const RoomModel = model<IRoom>(roomsCollection, RoomSchema);