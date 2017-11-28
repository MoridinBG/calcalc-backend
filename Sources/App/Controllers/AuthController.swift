import Vapor
import JWT
import AuthProvider

final class AuthController {
    fileprivate let jwtSecret: String

    init(jwtSecret: String) {
        self.jwtSecret = jwtSecret
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let id = try request.user().id?.wrapped.string else {
            throw Abort.unauthorized
        }

        let jwt = try newJWTToken(for: "\(id)")

        let authToken = AuthToken(token: try jwt.createToken(), userId: Node(id))
        try authToken.save()
        return JSON(["accessToken" : StructuredData.string(try jwt.createToken())])
    }
}

extension AuthController {
    fileprivate func newJWTToken(for id: String) throws -> JWT {
        let claims: [Claim] = [
            ExpirationTimeClaim(createTimestamp: { return Int(Date().timeIntervalSince1970) + 86400 }),
            SubjectClaim(string: "\(id)")
        ]

        return try JWT(payload: JSON(Node(claims)), signer: HS256(key: jwtSecret.bytes))
    }
}


