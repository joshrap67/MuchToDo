import express from 'express';
import * as userService from '../services/userService';
import {CreateUserRequest} from './requests/userRequests/createUserRequest';
import {SetTagRequest} from "./requests/userRequests/setTagRequest";
import {SetContactRequest} from "./requests/userRequests/setContactRequest";

export const getUser = async (_req: express.Request<{}, {}, {}>, res: express.Response) => {
    const id = res.locals.userId;
    const user = await userService.getUserById(id);

    return res.status(200).json(user);
}

export const createUser = async (req: express.Request<{}, {}, CreateUserRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const email = res.locals.email;
    const user = await userService.createUser(userId, email, req.body.rooms ?? []);

    return res.status(201).json(user);
}

export const createTag = async (req: express.Request<{}, {}, SetTagRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const tag = await userService.createTag(req.body.name, userId);

    return res.status(201).json(tag);
}

export const updateTag = async (req: express.Request<{ id: string }, {}, SetTagRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await userService.updateTag(req.params.id, req.body, userId);

    return res.status(204).send();
}

export const deleteTag = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await userService.deleteTag(req.params.id, userId);

    return res.status(204).send();
}

export const createContact = async (req: express.Request<{}, {}, SetContactRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    const contact = await userService.createContact(req.body.name, req.body.email, req.body.phoneNumber, userId);

    return res.status(201).json(contact);
}

export const updateContact = async (req: express.Request<{ id: string }, {}, SetContactRequest>, res: express.Response) => {
    const userId = res.locals.userId;
    await userService.updateContact(req.params.id, req.body, userId);

    return res.status(204).send();
}

export const deleteContact = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await userService.deleteContact(req.params.id, userId);

    return res.status(204).send();
}

export const deleteUser = async (_req: express.Request<{}, {}, {}>, res: express.Response) => {
    const userId = res.locals.userId;
    await userService.deleteUser(userId);

    return res.status(204).send();
}
