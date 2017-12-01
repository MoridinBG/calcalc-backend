import FluentProvider

struct CreateCalorieEntry: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(CalorieEntry.self) { builder in
            builder.id()
            builder.double("date")
            builder.string("description")
            builder.int("calories")
            builder.parent(User.self, optional: false, unique: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(CalorieEntry.self)
    }
}
