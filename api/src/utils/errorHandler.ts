import {NextFunction, Request, Response} from "express";
import {BadRequestException} from "../errors/exceptions/badRequestException";
import {ResourceNotFoundException} from "../errors/exceptions/resourceNotFoundException";
import crypto from "crypto";
import {ErrorResponse} from "../errors/errorResponse";

export const errorHandler = async (err: Error, _req: Request, res: Response, next: NextFunction) => {
    const uuid = crypto.randomUUID();
    console.error(`UUID: ${uuid}, ${err.stack}`);
    if (err instanceof BadRequestException) {
        res.status(400).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else if (err instanceof ResourceNotFoundException) {
        console.log('wtf');
        res.status(404).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else if (err instanceof Error) {
        res.status(500).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else {
        res.status(500).json({uuid: uuid, message: 'The server encountered an error'} as ErrorResponse);
    }
}