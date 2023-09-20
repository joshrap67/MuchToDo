import {NextFunction, Request, Response} from "express";
import {BadRequestException} from "../errors/exceptions/badRequestException";
import {ResourceNotFoundException} from "../errors/exceptions/resourceNotFoundException";
import crypto from "crypto";
import {ErrorResponse} from "../errors/errorResponse";
import {error, warn} from "firebase-functions/logger";

export const errorHandler = async (err: Error, _req: Request, res: Response, next: NextFunction) => {
    const uuid = crypto.randomUUID();
    if (err instanceof BadRequestException) {
        warn(`UUID: ${uuid}, ${err.stack}`);
        res.status(400).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else if (err instanceof ResourceNotFoundException) {
        warn(`UUID: ${uuid}, ${err.stack}`);
        res.status(404).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else if (err instanceof Error) {
        error(`UUID: ${uuid}, ${err.stack}`);
        res.status(500).json({uuid: uuid, message: err.message} as ErrorResponse);
    } else {
        error(`UUID: ${uuid}, ${err}`);
        res.status(500).json({uuid: uuid, message: 'The server encountered an error'} as ErrorResponse);
    }
}