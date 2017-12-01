import FluentProvider

final class CalorieEntry: Model, Timestampable {
    var userId: Node
    var date: Double
    var description: String
    var calories: Int
    
    var storage = Storage()
    
    func user() throws -> User {
        guard let user = try parent(id: Fluent.Identifier(userId), type: User.self).first() else {
            throw Abort(.notFound, reason: "User for CalorieEntry not found", identifier: ErrorIdentifiers.Database.parentNotFound)
        }
        
        return user
    }
    
    init(userId: Node, date: Double, description: String, calories: Int) {
        self.userId = userId
        self.date = date
        self.description = description
        self.calories = calories
    }
    
    init(row: Row) throws {
        userId = try row.get("user_id")
        date = try row.get("date")
        description = try row.get("description")
        calories = try row.get("calories")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("user_id", userId)
        try row.set("date", date)
        try row.set("description", description)
        try row.set("calories", calories)
        
        return row
    }
}

extension CalorieEntry: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(userId: json.get("userId"),
                      date: json.get("date"),
                      description: json.get("description"),
                      calories: json.get("calories"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("userId", userId)
        try json.set("date", date)
        try json.set("description", description)
        try json.set("calories", calories)
        
        return json
    }
}

