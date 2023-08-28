import {
    createUser,
    getUser,
    createContact,
    createTag,
    updateTag,
    updateContact,
    deleteTag, deleteContact, deleteUser
} from '../controllers/userController';
import express from 'express';

export default (router: express.Router) => {
    router.get('/users', (req, res) => getUser(req, res));
    router.post('/users', (req, res) => createUser(req, res));
    router.delete('/users', (req, res) => deleteUser(req, res));
    router.post('/users/tags', (req, res) => createTag(req, res));
    router.put('/users/tags/:id', (req, res) => updateTag(req, res));
    router.delete('/users/tags/:id', (req, res) => deleteTag(req, res));
    router.post('/users/contacts', (req, res) => createContact(req, res));
    router.put('/users/contacts/:id', (req, res) => updateContact(req, res));
    router.delete('/users/contacts/:id', (req, res) => deleteContact(req, res));
};