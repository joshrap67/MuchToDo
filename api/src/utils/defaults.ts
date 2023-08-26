import {ITag} from "../domain/user";
import * as crypto from "crypto";

export const defaultTags = [
    {id: crypto.randomUUID(), name: 'Decoration', tasks: []},
    {id: crypto.randomUUID(), name: 'Electrical', tasks: []},
    {id: crypto.randomUUID(), name: 'Maintenance', tasks: []},
    {id: crypto.randomUUID(), name: 'Outside', tasks: []},
    {id: crypto.randomUUID(), name: 'Painting', tasks: []},
    {id: crypto.randomUUID(), name: 'Plumbing', tasks: []},
    {id: crypto.randomUUID(), name: 'Structural', tasks: []}
] as ITag[];