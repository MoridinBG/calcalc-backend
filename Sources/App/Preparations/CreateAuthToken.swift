import FluentProvider

struct CreateAuthToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(AuthToken.self) { builder in
            builder.id()
            builder.string("token")
            builder.parent(User.self, optional: false, unique: false)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(AuthToken.self)
    }
}
