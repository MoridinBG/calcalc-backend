
import FluentProvider
import AuthProvider

fileprivate let minPassLength = 3

final class User: Model, Timestampable, ResponseRepresentable {
    enum Role: String {
        case user
        case manager
        case admin
    }
    
    var email: String
    var hashedPassword: String?
    var firstName: String
    var lastName: String
    
    var role: Role
    
    let storage = Storage()
    
    init(email: String, password: String?, firstName: String, lastName: String, role: Role) throws {
        guard email.isEmail else {
            throw Abort(.badRequest, reason: "You must provide a valid email address", identifier: ErrorIdentifiers.Validation.User.invalidEmail)
        }
        
        guard (password?.characters.count ?? minPassLength) >= minPassLength else {
            throw Abort(.badRequest, reason: "Your password must be minimum \(minPassLength)", identifier: ErrorIdentifiers.Validation.User.invalidPassword)
        }
        
        guard try User.makeQuery().filter("email", email).count() == 0 else {
            throw Abort(.conflict, reason: "The email address is in use", identifier: ErrorIdentifiers.Validation.User.emailInUse)
        }
        
        var hashedPassword: String? = nil
        if let password = password {
            hashedPassword = String(bytes: try BCryptHasher().make(password))
        }
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.hashedPassword = hashedPassword
    }
    
    init(row: Row) throws {
        let roleString: String = try row.get("role")
        guard let role = Role(rawValue: roleString) else {
            throw Abort(.badRequest, reason: "Your password must be minimum \(minPassLength)", identifier: ErrorIdentifiers.Validation.User.unknownRole)
        }
        
        email = try row.get("email")
        hashedPassword = try row.get("password_hash")
        firstName = try row.get("first_name")
        lastName = try row.get("last_name")
        self.role = role
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("email", email)
        try row.set("first_name", firstName)
        try row.set("last_name", lastName)
        try row.set("role", role.rawValue)
        
        if let hashedPassword = hashedPassword {
            try row.set("password_hash", hashedPassword)
        }
        
        return row
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        guard let roleString: String = try json.get("role"), let role = Role(rawValue: roleString) else {
            throw "Could not get role from JSON"
        }
        
        try self.init(email: json.get("email"),
                      password: json.get("password"),
                      firstName: json.get("first_name"),
                      lastName: json.get("last_name"),
                      role: role)
    }
    
    func makeJSON() throws -> JSON {
        var userJson = JSON()
        try userJson.set("id", id)
        try userJson.set("email", email)
        try userJson.set("first_name", firstName)
        try userJson.set("last_name", lastName)
        try userJson.set("role", role.rawValue)
        
        return userJson
    }
}

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken
}

extension User: PasswordAuthenticatable {
    public static var passwordVerifier: PasswordVerifier? {
        return BCryptHasher()
    }
}