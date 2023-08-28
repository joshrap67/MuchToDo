import {IContact, ITag, IUser} from "../../domain/user";
import {IContactResponse, ITagResponse, IUserResponse} from "../../controllers/responses/userResponse";

export const mapUserToResponse = (user: IUser): IUserResponse => {
    return {
        id: user._id.toHexString(),
        firebaseId: user.firebaseId,
        email: user.email,
        tags: user.tags.map(t => mapTagToResponse(t)),
        contacts: user.contacts.map(c => mapContactToResponse(c)),
        rooms: user.rooms.map(x => x.toHexString()),
        tasks: user.tasks.map(x => x.toHexString())
    };
}

export const mapTagToResponse = (tag: ITag): ITagResponse => {
    return {
        id: tag.id,
        name: tag.name,
        tasks: tag.tasks.map(x => x.toHexString())
    };
}

export const mapContactToResponse = (contact: IContact): IContactResponse => {
    return {
        id: contact.id,
        name: contact.name,
        email: contact.email,
        phoneNumber: contact.phoneNumber,
        tasks: contact.tasks.map(x => x.toHexString())
    };
}