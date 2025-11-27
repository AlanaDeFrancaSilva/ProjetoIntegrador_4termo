import { URGENCY_LEVEL } from "./enums.model";
import { TASK_STATUS } from "./enums.model";  // ⬅️ IMPORTANTE
import type { Equipment } from "./equipment.model";
import { User } from "./user.model";

export class Task {
    id: number = 0;
    name: string = "";
    description: string = "";
    suggested_date: Date = new Date();
    urgency_level: URGENCY_LEVEL = URGENCY_LEVEL.LOW;
    task_status: TASK_STATUS = TASK_STATUS.ABERTO;  // ⬅️ CAMPO NOVO
    creation_date: Date = new Date();
    creator_FK: User = new User();
    equipments_FK: Array<Equipment> = [];
    responsibles_FK: Array<User> = [];
}
