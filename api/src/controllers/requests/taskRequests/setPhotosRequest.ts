export interface ISetPhotosRequest{
    deletedPhotos: string[];
    photosToUpload: string[]; // base64 encoded
}