import {Request, Response, NextFunction} from 'express';
import JwksRsa from 'jwks-rsa';
import jwt, {JwtPayload} from 'jsonwebtoken';

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
                issuer: 'https://securetoken.google.com/muchtodo-42777' // no need to keep this secret as its in the payload which is not encrypted
            }, function (error, decoded: JwtPayload) {
                if (error) {
                    console.log(error);
                    return res.status(403).end();
                }

                if (!decoded.email_verified) {
                    return res.status(403).end();
                }

                // below are now available to any controller
                res.locals.firebaseId = decoded.user_id;
                res.locals.email = decoded.email;

                next();
            });
        } catch (error) {
            console.log(error);
            return res.status(403).end();
        }
    } catch (error) {
        return res.status(500).end();
    }

};