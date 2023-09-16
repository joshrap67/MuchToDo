import {Contact, Tag, User} from "../../domain/user";
import {ContactResponse, TagResponse, UserResponse} from "../../controllers/responses/userResponse";

export const mapUserToResponse = (user: User): UserResponse => {
    return {
        id: user._id,
        email: user.email,
        tags: user.tags.map(t => mapTagToResponse(t)),
        contacts: user.contacts.map(c => mapContactToResponse(c)),
        rooms: user.rooms.map(x => x.toHexString()),
        tasks: user.tasks.map(x => x.toHexString())
    } as UserResponse;
}

export const mapTagToResponse = (tag: Tag): TagResponse => {
    return {
        id: tag.id,
        name: tag.name,
        tasks: tag.tasks.map(x => x.toHexString())
    };
}

export const mapContactToResponse = (contact: Contact): ContactResponse => {
    return {
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        tasks: contact.tasks.map(x => x.toHexString())
    };
}