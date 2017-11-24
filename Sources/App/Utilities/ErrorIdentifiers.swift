struct ErrorIdentifiers {
    struct Server {
        static let internalError = "Server.internalError"
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
}
