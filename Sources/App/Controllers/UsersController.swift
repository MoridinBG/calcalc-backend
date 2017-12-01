import Vapor
import HTTP

final class UsersController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(index: index,
                        replace: replace,
                        destroy: destroy)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        guard var userJson = request.json?["user"] else {
            throw Abort(Status.badRequest, reason: "'user' must be supplied as JSON", identifier: ErrorIdentifiers.User.Create.missingUserJson)
        }

        guard userJson["password"] != nil else {
            throw Abort(Status.badRequest, reason: "'password' must be supplied when creating users JSON", identifier: ErrorIdentifiers.User.Create.missingPassword)
        }

        // Make sure that only managers/admins can specify roles for new users
        do {
            let requestUser = try request.user()
            guard (userJson["role"] != nil && requestUser.role != .user) || (userJson["role"] == nil) else {
                throw Abort(Status.unauthorized, reason: "Normal users can not specify 'role'", identifier: ErrorIdentifiers.User.Create.roleNotAllowed)
            }
            
            if userJson["role"] == "admin" && requestUser.role != .admin {
                throw Abort(Status.unauthorized, reason: "Only admins can create other admins", identifier: ErrorIdentifiers.User.Create.roleNotAllowed)
            }
            
            if userJson["role"] == nil {
                userJson["role"] = "user"
            }
        } catch {
            
            if let requestUser = try? request.user(), userJson["role"] == "admin" && requestUser.role != .admin {
                throw Abort(Status.unauthorized, reason: "Only admins can create other admins", identifier: ErrorIdentifiers.User.Create.roleNotAllowed)
            }
            
            guard userJson["role"] == nil || userJson["role"] == "user" else {
                throw Abort(Status.unauthorized, reason: "Normal users can not specify 'role'", identifier: ErrorIdentifiers.User.Create.roleNotAllowed)
            }
            
            userJson["role"] = "user"
        }
        
        let user = try User(json: userJson)
        try user.save()

        return JSON([
            "user" : try user.makeJSON()
        ])
    }

    func index(request: Request) throws -> ResponseRepresentable {
        return JSON([
            "user" : try request.user().makeJSON()
        ])
    }

    func destroy(request: Request, user: User) throws -> ResponseRepresentable {
        let requestUser = try request.user()

        guard requestUser.role != .user else {
            throw Abort(.forbidden, reason: "You are not allowed to manage users", identifier: ErrorIdentifiers.User.Destroy.notAllowed)
        }

        guard requestUser.id != user.id else {
            throw Abort(.forbidden, reason: "You are not allowed to delete self", identifier: ErrorIdentifiers.User.Destroy.notAllowed)
        }

        if requestUser.role == .manager && user.role == .admin {
            throw Abort(.forbidden, reason: "You are not allowed to manage admins", identifier: ErrorIdentifiers.User.Destroy.notAllowed)
        }

        try AuthToken.makeQuery().filter("user_id", user.id).delete()
        
        try user.delete()
        return Response(status: .noContent)
    }

    func replace(request: Request, user: User) throws -> ResponseRepresentable {
        let requestUser = try request.user()

        guard requestUser.id == user.id || requestUser.role != .user else {
            throw Abort(.forbidden, reason: "You are not allowed to manage other users", identifier: ErrorIdentifiers.User.Update.notAllowed)
        }
        
        // Only allow admins to edit other admins
        if user.role == .admin {
            guard requestUser.role == .admin else {
                throw Abort(.unauthorized, reason: "You are not allowed to manage admins", identifier: ErrorIdentifiers.User.Update.notAllowed)
            }
        }

        guard let userJson = request.json?["user"] else {
            throw Abort(.badRequest, reason: "'user' must be supplied as JSON", identifier: ErrorIdentifiers.User.Update.missingUserJson)
        }

        if requestUser.role == .user, let roleString = userJson["role"]?.string, roleString != User.Role.user.rawValue {
            throw Abort(.unauthorized, reason: "You are not allowed to manage your role", identifier: ErrorIdentifiers.User.Update.notAllowed)
        }
        
        let role: String = (user.id == requestUser.id) ? (try userJson.get("role") ?? requestUser.role.rawValue) : (try userJson.get("role") ?? "user")
        
        if try User.makeQuery().filter("role", "admin").count() == 1, user.role == .admin, role != "admin" {
            throw Abort(.unauthorized, reason: "You are the last admin.", identifier: ErrorIdentifiers.User.Update.notAllowed)
        }

        user.email = try userJson.get("email")
        user.firstName = try userJson.get("first_name")
        user.lastName = try userJson.get("last_name")
        user.role = User.Role(rawValue: role) ?? .user

        var hashedPassword: String? = nil
        let password: String? = try userJson.get("password")
        if let password = password {
            hashedPassword = String(bytes: try BCryptHasher().make(password))
        }
        user.hashedPassword = hashedPassword

        try user.save()

        return JSON([
            "user" : try user.makeJSON()
        ])
    }

    func getAll(request: Request) throws -> ResponseRepresentable {
        let requestUser = try request.user()
        guard requestUser.role != .user else {
            throw Abort(.forbidden, reason: "You are not allowed to manage other users", identifier: ErrorIdentifiers.User.Destroy.notAllowed)
        }

        let userJson = try User.makeQuery().all().makeJSON()

        return JSON([
            "users" : userJson
        ])
    }
}

extension UsersController: EmptyInitializable {}
