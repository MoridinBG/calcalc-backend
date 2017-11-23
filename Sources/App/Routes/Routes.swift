import Vapor
import AuthProvider

final class Routes: RouteCollection {
    fileprivate let jwtSecret: String
    
    init(jwtSecret: String) {
        self.jwtSecret = jwtSecret
    }
    
    func build(_ builder: RouteBuilder) throws {
    }
}
