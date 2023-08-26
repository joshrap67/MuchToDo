import express from 'express';
import * as userService from '../services/userService';
import {ICreateUserRequest} from './requests/userRequests/createUserRequest';
import {ICreateTagRequest} from "./requests/userRequests/createTagRequest";
import {IContact, ITag} from "../domain/user";
import {ICreateContactRequest} from "./requests/userRequests/createContactRequest";

export const getUser = async (req: express.Request<{}, {}, {}>, res: express.Response) => {
    try {
        const id = res.locals.firebaseId;
        const user = await userService.getUserByFirebaseId(id);

        return res.status(200).json(user);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400); // todo 404
    }
}

export const createUser = async (req: express.Request<{}, {}, ICreateUserRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const email = res.locals.email;
        const user = await userService.createUser(firebaseId, email, req.body.rooms);

        return res.status(201).json(user);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createTag = async (req: express.Request<{}, {}, ICreateTagRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const tag = await userService.createTag(req.body.name, firebaseId);

        return res.status(201).json(tag);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const updateTag = async (req: express.Request<{ id: string }, {}, ITag>, res: express.Response) => {
    try {
        // todo have requests for these instead of reusing domain
        const firebaseId = res.locals.firebaseId;
        await userService.updateTag(req.body, firebaseId);

        return res.status(204);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteTag = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        // todo have requests for these instead of reusing domain
        const firebaseId = res.locals.firebaseId;
        await userService.deleteTag(req.params.id, firebaseId);

        return res.status(204);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const createContact = async (req: express.Request<{}, {}, ICreateContactRequest>, res: express.Response) => {
    try {
        const firebaseId = res.locals.firebaseId;
        const contact = await userService.createContact(req.body.name, req.body.email, req.body.phoneNumber, firebaseId);

        return res.status(201).json(contact);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const updateContact = async (req: express.Request<{ id: String }, {}, IContact>, res: express.Response) => {
    try {
        // todo have requests for these instead of reusing domain
        const firebaseId = res.locals.firebaseId;
        await userService.updateContact(req.body, firebaseId);

        return res.status(204);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

export const deleteContact = async (req: express.Request<{ id: string }, {}, {}>, res: express.Response) => {
    try {
        // todo have requests for these instead of reusing domain
        const firebaseId = res.locals.firebaseId;
        await userService.deleteContact(req.params.id, firebaseId);

        return res.status(204);
    } catch (error) {
        console.log(error);
        return res.sendStatus(400);
    }
}

