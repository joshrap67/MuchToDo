import {Request, Response, NextFunction} from 'express';
import JwksRsa from 'jwks-rsa';
import jwt, {JwtPayload} from 'jsonwebtoken';
import {validationResult} from "express-validator";
import {ErrorResponse} from "../errors/errorResponse";
import crypto from "crypto";

const jwksClient = JwksRsa({
    jwksUri: 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'
});

export const authenticateJWT = async (req: Request, res: Response, next: NextFunction): Promise<Response> => {
    try {
        const encodedToken = req.headers.authorization?.replace("Bearer ", "") || "";
        if (!encodedToken) {
            return res.status(401).end();
        }
        const decodedToken = jwt.decode(encodedToken, {complete: true});
        if (!decodedToken) {
            return res.status(401).end();
        }

        try {
            const signingKey = await jwksClient.getSigningKey(decodedToken.header.kid);
            jwt.verify(encodedToken, signingKey.getPublicKey(), {
                algorithms: ["RS256"],
                issuer: 'https://securetoken.google.com/muchtodo-42777' // no need to keep this secret as it's in the payload which is not encrypted
            }, function (error, decoded: JwtPayload) {
                if (error) {
                    console.log(error);
                    return res.status(401).end();
                }

                if (!decoded.email_verified) {
                    return res.status(403).json({
                        message: 'Email is not verified',
                        uuid: crypto.randomUUID()
                    } as ErrorResponse);
                }

                // below are now available to any controller
                res.locals.userId = decoded.user_id;
                res.locals.email = decoded.email;

                next();
            });
        } catch (error) {
            console.log(error);
            return res.status(401).end();
        }
    } catch (error) {
        return res.status(500).end();
    }
};

export const checkError = (req: Request, res: Response, next: NextFunction) => {
    const error = validationResult(req).formatWith(({msg}) => msg);

    if (!error.isEmpty()) {
        res.status(400).json({message: error.array().toString(), uuid: crypto.randomUUID()} as ErrorResponse);
    } else {
        next();
    }
}