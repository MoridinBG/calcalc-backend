import Vapor
import HTTP

final class CalorieEntriesController: ResourceRepresentable {
    func makeResource() -> Resource<CalorieEntry> {
        return Resource(index: index,
                        store: create,
                        replace: replace,
                        destroy: destroy)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        guard var entryJson = request.json?["entry"] else {
            throw Abort(Status.badRequest, reason: "'entry' must be supplied as JSON", identifier: ErrorIdentifiers.CalorieEntry.Create.missingEntryJson)
        }
        
        if let targetUser = try? request.parameters.next(User.self) {
            try entryJson.set("userId", targetUser.id)
        } else {
            try entryJson.set("userId", user.id)
        }
        
        let entry = try CalorieEntry(json: entryJson)
        try entry.save()
        
        let json = JSON([
            "entry" : try entry.makeJSON()
        ])
        
        return try Response(status: .created, json: json)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let requestUser = try request.user()
        
        guard requestUser.role == .admin else {
            let userEntries = try requestUser.entries().sorted { $0.date < $1.date }
            return JSON([[
                "user" : try requestUser.makeJSON(),
                "entries" : try userEntries.makeJSON()
            ]])
        }
        
        var entries = [JSON]()
        for user in try User.makeQuery().all().filter({ try $0.entries().count > 0 }) {
            let userEntries = try user.entries().sorted { $0.date < $1.date }
            entries.append(JSON([
                "user" : try user.makeJSON(),
                "entries" : try userEntries.makeJSON()
            ]))
        }
        
        return try entries.makeJSON()
    }
    
    func destroy(request: Request, entry: CalorieEntry) throws -> ResponseRepresentable {
        let requestUser = try request.user()
        let entryUser = try entry.user()
        
        guard entryUser.id == requestUser.id || requestUser.role == .admin else {
            throw Abort(.forbidden, reason: "You are not allowed to edit this entry", identifier: ErrorIdentifiers.CalorieEntry.Destroy.notAllowed)
        }
        
        try entry.delete()
        
        return Response(status: .noContent)
    }
    
    func replace(request: Request, entry: CalorieEntry) throws -> ResponseRepresentable {
        let requestUser = try request.user()
        let entryUser = try entry.user()
        
        guard entryUser.id == requestUser.id || requestUser.role == .admin else {
            throw Abort(.forbidden, reason: "You are not allowed to edit this entry", identifier: ErrorIdentifiers.CalorieEntry.Replace.notAllowed)
        }
        
        guard let entryJson = request.json?["entry"] else {
            throw Abort(.badRequest, reason: "'entry' must be supplied as JSON", identifier: ErrorIdentifiers.CalorieEntry.Replace.missingEntryJson)
        }
        
        if let updatedUserId: Int = try? entryJson.get("userId") {
            if updatedUserId != entryUser.id?.int && requestUser.role != .admin {
                throw Abort(.forbidden, reason: "You are not allowed to assign other people as owners of this entry", identifier: ErrorIdentifiers.CalorieEntry.Replace.notAllowed)
            }
            
            guard try User.makeQuery().find(updatedUserId) != nil else {
                throw Abort(.badRequest, reason: "New entry owner not found", identifier: ErrorIdentifiers.CalorieEntry.Replace.newOwnerNotFound)
            }

            entry.userId = Node(updatedUserId)
        }
        
        entry.date = try entryJson.get("date")
        entry.description = try entryJson.get("description")
        entry.calories = try entryJson.get("calories")
        
        try entry.save()
        
        return JSON([
            "entry" : try entry.makeJSON()
            ])
    }
}
