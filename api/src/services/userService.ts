import { IUser, UserModel } from "domain/user"
import mongoose, { Types } from "mongoose";


export async function getUserByFirebaseId(firebaseId: string): Promise<IUser> {
    const user = await UserModel.findOne({ 'firebaseId': { firebaseId } });
    return user;
}

export async function getUserById(id: Types.ObjectId): Promise<IUser> {
    const user = await UserModel.findOne({ '_id': { id } });
    return user;
}

