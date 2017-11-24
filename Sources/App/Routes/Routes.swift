import Vapor
import AuthProvider

final class Routes: RouteCollection {
    fileprivate let jwtSecret: String
    
    init(jwtSecret: String) {
        self.jwtSecret = jwtSecret
    }
    
    func build(_ builder: RouteBuilder) throws {
        let tokenAuthenticator = TokenAuthenticationMiddleware(User.self)
        let passwordAuthenticator = PasswordAuthenticationMiddleware(User.self)
        
        let apiV1 = builder.grouped("api").grouped("v1")
        let apiV1Authenticated = apiV1.grouped(tokenAuthenticator)
        
        // MARK: Auth
        
        apiV1.grouped("auth").grouped(passwordAuthenticator).post("login", handler: AuthController(jwtSecret: jwtSecret).login)
        
        // MARK: Users
        apiV1.post("users", handler: UsersController().create) // Creating new users does not need authentication
        apiV1Authenticated.post("users", "managed", handler: UsersController().create) // Authenticated user creation for managers/admins
        
        apiV1Authenticated.resource("users", UsersController())
        apiV1Authenticated.get("users", "all", handler: UsersController().getAll)
    }
}
