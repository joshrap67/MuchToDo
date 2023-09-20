import {Contact, Tag} from "../domain/user";

export function sortTagsAlpha(tags: Tag[]): void {
    tags.sort(function (a, b) {
        return Intl.Collator().compare(a.name, b.name);
    });
}

export function sortContactsAlpha(contacts: Contact[]): void {
    contacts.sort(function (a, b) {
        return Intl.Collator().compare(a.name, b.name);
    });
}