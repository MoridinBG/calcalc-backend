struct ErrorIdentifiers {
    struct Server {
        static let internalError = "Server.internalError"
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
