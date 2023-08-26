import {IUser} from "../../domain/user";
import {IContactResponse, ITagResponse, IUserResponse} from "../../controllers/responses/userResponse";

export const mapUserToResponse = (user: IUser): IUserResponse => {
    const contacts: IContactResponse[] = [];
    const tags: ITagResponse[] = [];
    for (const tag of user.tags) {
        tags.push({
            id: tag.id,
            name: tag.name,
            tasks: tag.tasks.map(x => x.toHexString())
        });
    }
    for (const contact of user.contacts) {
        contacts.push({
            id: contact.id,
            name: contact.name,
            email: contact.email,
            phoneNumber: contact.phoneNumber,
            tasks: contact.tasks.map(x => x.toHexString())
        });
    }
    return {
        id: user._id.toHexString(),
        firebaseId: user.firebaseId,
        email: user.email,
        tags: tags,
        contacts: contacts,
        rooms: user.rooms.map(x => x.toHexString()),
        tasks: user.tasks.map(x => x.toHexString())
    };
}