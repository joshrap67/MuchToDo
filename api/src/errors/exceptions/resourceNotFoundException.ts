export class ResourceNotFoundException extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'ResourceNotFoundException';

        Object.setPrototypeOf(this, ResourceNotFoundException.prototype);
    }
}