import { ITask, TaskModel } from "domain/task"
import { ITag, IContact, UserModel } from "domain/user"
import mongoose, { Types } from "mongoose";
import { RoomModel } from "domain/room";
import { convertTaskToRoomTask } from "domain/utils/converter";

export async function getTasksByUser(ids: mongoose.Types.ObjectId[], userId: mongoose.Types.ObjectId): Promise<ITask[]> {
    const tasks = await TaskModel.find({ '_id': { $in: ids }, 'createdBy': { userId } });
    return tasks;
}

export async function createTasks(userId: mongoose.Types.ObjectId, tasks: ITask[]): Promise<ITask[]> {
    const user = await UserModel.findOne({ '_id': { userId } });
    for (const task of tasks) {
        task.createdBy = user.id;
        task.creationDate = new Date();
    }

    let createdTasks: ITask[] = [];
    const session = await mongoose.startSession();
    await session.withTransaction(async()=>{
        createdTasks = await TaskModel.create([tasks], {session: session});

        const tagIdToTag: Record<string, ITag> = {};
        const contactIdToContact: Record<string, IContact> = {};
        const roomIds: Types.ObjectId[] = [];
        const roomIdToTask: Record<string, ITask> = {};
        
        // update user
        for (const tag of user.tags) {
            tagIdToTag[tag.id.toString()] = tag;
        }
        for (const contact of user.contacts) {
            contactIdToContact[contact.id.toString()] = contact;
        }

        for (const task of createdTasks) {
            for (const taskTag of task.tags) {
                const tag = tagIdToTag[taskTag.id];
                tag?.tasks.push(task.id);
            }

            for (const taskContact of task.contacts) {
                const contact = contactIdToContact[taskContact.id];
                contact?.tasks.push(task.id);
            }
            roomIds.push(task.room.id);
            roomIdToTask[task.room.id.toString()] = task;

            user.tasks.push(task.id);
        }
        
        await user.save({ session: session });

        // update rooms
        const rooms = await RoomModel.find({'_id': {$in: roomIds}});
        for(const room of rooms){
            const task = roomIdToTask[room.id];
            room.tasks.push(convertTaskToRoomTask(task));
            room.save({session: session});
        }
    });
    await session.endSession();
    

    return createdTasks;
}