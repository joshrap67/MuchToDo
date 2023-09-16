export interface UserResponse {
    id: string;
    email: string;
    tags: TagResponse[];
    contacts: ContactResponse[];
    tasks: string[];
    rooms: string[];
}

export interface TagResponse {
    id: string;
    name: string;
    tasks: string[];
}

export interface ContactResponse {
    id: string;
    name: string;
    email: string;
    phoneNumber: string;
    tasks: string[];
}