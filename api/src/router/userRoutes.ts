import {
    createUser,
    getUser,
    createContact,
    createTag,
    updateTag,
    updateContact,
    deleteTag, deleteContact, deleteUser
} from '../controllers/userController';
import express, {NextFunction, Request, Response} from 'express';
import {setContactSchema} from "../controllers/requests/userRequests/setContactRequest";
import {setTagSchema} from "../controllers/requests/userRequests/setTagRequest";
import {createUserSchema} from "../controllers/requests/userRequests/createUserRequest";
import {checkError} from "../utils/httpUtils";

export default (router: express.Router) => {
    router.get('/users', (req, res) => getUser(req, res));
    router.post('/users',
        createUserSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => createUser(req, res));
    router.delete('/users', (req, res) => deleteUser(req, res));
    router.post('/users/tags',
        setTagSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => createTag(req, res));
    router.put('/users/tags/:id',
        setTagSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => updateTag(req, res));
    router.delete('/users/tags/:id', (req, res) => deleteTag(req, res));
    router.post('/users/contacts',
        setContactSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request, res: Response) => createContact(req, res));
    router.put('/users/contacts/:id',
        setContactSchema(),
        (req: Request, res: Response, next: NextFunction) => checkError(req, res, next),
        (req: Request<{ id: string }>, res: Response) => updateContact(req, res));
    router.delete('/users/contacts/:id', (req, res) => deleteContact(req, res));
};