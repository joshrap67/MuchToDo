import {checkSchema} from "express-validator";
import {
    maxContacts,
    maxEffort, maxLinks,
    maxPriority,
    maxTags,
    maxTaskName,
    maxTaskNote,
    minEffort,
    minPriority
} from "../../../utils/constants";

export interface CreateTaskRequest {
    name: string;
    priority: number;
    effort: number;
    roomId: string;
    estimatedCost: number;
    note: string;
    tagIds: string[];
    contactIds: string[];
    links: string[];
    inProgress: boolean;
    completeBy: Date;
}

export const createTaskSchema = () => {
    return checkSchema({
        name: {
            trim: true,
            notEmpty: {errorMessage: 'Name cannot be empty'},
            isLength: {
                options: {max: maxTaskName},
                errorMessage: `Name cannot be more than ${maxTaskName} characters`
            }
        },
        priority: {
            isInt: {errorMessage: 'Priority must be an integer'},
            notEmpty: {errorMessage: 'Priority cannot be empty'},
            isLength: {
                options: {min: minPriority, max: maxPriority},
                errorMessage: `Priority must be between ${minPriority} and ${maxPriority}`
            }
        },
        effort: {
            isInt: {errorMessage: 'Effort must be an integer'},
            notEmpty: {errorMessage: 'Effort cannot be empty'},
            isLength: {
                options: {min: minEffort, max: maxEffort},
                errorMessage: `Effort must be between ${minEffort} and ${maxEffort}`
            }
        },
        roomId: {
            notEmpty: {errorMessage: 'Room cannot be empty'},
        },
        estimatedCost: {
            optional: {options: {values: 'falsy'}},
            isDecimal: {errorMessage: 'The estimated cost price must be a decimal'}
        },
        note: {
            optional: true,
            trim: true,
            isLength: {
                options: {max: maxTaskNote},
                errorMessage: `Note cannot be more than ${maxTaskNote} characters`
            }
        },
        completeDate: {
            optional: true,
            isISO8601: {errorMessage: 'Date not in proper format (ISO8601)'}
        },
        tagIds: {
            optional: true,
            isArray: {options: {max: maxTags}, errorMessage: `Cannot have more than ${maxTags} tags`},
        },
        contactIds: {
            optional: true,
            isArray: {options: {max: maxContacts}, errorMessage: `Cannot have more than ${maxContacts} contacts`},
        },
        links: {
            optional: true,
            isArray: {options: {max: maxLinks}, errorMessage: `Cannot have more than ${maxLinks} links`},
        }
    }, ['body']);
}