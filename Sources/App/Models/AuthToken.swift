import FluentProvider

final class AuthToken: Model, Timestampable {
    let token: String
    let userId: Node
    
    init(token: String, userId: Node) {
        self.token = token
        self.userId = userId
    }
    
    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get("user_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user_id", userId)
        
        return row
    }
    
    var storage = Storage()
}

extension AuthToken: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(token: json.get("token"),
                      userId: json.get("userId"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("token", token)
        try json.set("userId", userId)
        
        return json
    }
}
