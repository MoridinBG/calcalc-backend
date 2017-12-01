
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
    var calorieTarget: Int?
    
    var role: Role
    
    let storage = Storage()
    
    func entries() throws -> [CalorieEntry] {
        return try children(type: CalorieEntry.self).all()
    }
    
    init(email: String, password: String?, firstName: String, lastName: String, calorieTarget: Int?, role: Role) throws {
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
        self.calorieTarget = calorieTarget
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
        calorieTarget = try row.get("calorie_target")
        self.role = role
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("email", email)
        try row.set("first_name", firstName)
        try row.set("last_name", lastName)
        try row.set("role", role.rawValue)
        try row.set("calorie_target", calorieTarget)
        
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
                      firstName: json.get("firstName"),
                      lastName: json.get("lastName"),
                      calorieTarget: json.get("calorieTarget"),
                      role: role)
    }
    
    func makeJSON() throws -> JSON {
        var userJson = JSON()
        try userJson.set("id", id)
        try userJson.set("email", email)
        try userJson.set("firstName", firstName)
        try userJson.set("lastName", lastName)
        try userJson.set("role", role.rawValue)
        try userJson.set("calorieTarget", calorieTarget)
        
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
