import {
    createUser,
    getUser,
    createContact,
    createTag,
    updateTag,
    updateContact,
    deleteTag, deleteContact
} from '../controllers/userController';
import express from 'express';

export default (router: express.Router) => {
    // todo 'self' instead of 'user'?
    router.get('/user', (req, res) => getUser(req, res));
    router.post('/user', (req, res) => createUser(req, res));
    router.post('/user/tags', (req, res) => createTag(req, res));
    router.put('/user/tags/:id', (req, res) => updateTag(req, res));
    router.delete('/user/tags/:id', (req, res) => deleteTag(req, res));
    router.post('/user/contacts', (req, res) => createContact(req, res));
    router.put('/user/contacts/:id', (req, res) => updateContact(req, res));
    router.delete('/user/contacts/:id', (req, res) => deleteContact(req, res));
};