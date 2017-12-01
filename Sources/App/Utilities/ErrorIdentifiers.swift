struct ErrorIdentifiers {
    struct Server {
        static let internalError = "Server.internalError"
    }
    
    struct User {
        struct Create {
            static let missingUserJson = "User.Create.missingUserJson"
            static let missingPassword = "User.Create.missingPassword"
            static let roleNotAllowed = "User.Create.roleNotAllowed"
        }
        
        struct Update {
            static let missingUserJson = "User.Update.missingUserJson"
            static let notAllowed = "User.Update.notAllowed"
        }
        
        struct Destroy {
            static let notAllowed = "User.Destroy.notAllowed"
        }
    }
    
    struct CalorieEntry {
        struct Create {
            static let missingEntryJson = "CalorieEntry.Create.missingUserJson"
        }
        
        struct Replace {
            static let notAllowed = "CalorieEntry.Replace.notAllowed"
            static let missingEntryJson = "CalorieEntry.Replace.missingUserJson"
            static let newOwnerNotFound = "CalorieEntry.Replace.newOwnerNotFound"
        }
        
        struct Destroy {
            static let notAllowed = "CalorieEntry.Destroy.notAllowed"
        }
    }
    
    struct Authentication {
        static let tokenExpired = "Authentication.tokenExpired"
        static let tokenInvalid = "Authentication.tokenInvalid"
    }
    
    struct Validation {
        struct User {
            static let invalidEmail = "Validation.User.invalidEmail"
            static let invalidPassword = "Validation.User.invalidPassword"
            static let emailInUse = "Validation.User.emailInUse"
            static let unknownRole = "Validation.User.unknownRole"
        }
    }
    
    struct Database {
        static let parentNotFound = "Databse.parentNotFound"
    }
}
