import FluentProvider

struct CreateUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(User.self) { builder in
            builder.id()
            builder.string("email", unique: true)
            builder.string("password_hash", optional: true)
            builder.string("first_name")
            builder.string("last_name")
            builder.string("role")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(User.self)
    }

}


