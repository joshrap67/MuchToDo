import { IRoomTask } from "domain/room"
import { ITask } from "domain/task"

export const convertTaskToRoomTask = (task: ITask): IRoomTask => {
    return { id: task.id, name: task.name, estimatedCost: task.estimatedCost, isActive: !task.isCompleted };
}