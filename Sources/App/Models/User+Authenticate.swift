import HTTP
import JWT
import AuthProvider

extension User {
    static func authenticate(_ token: Token) throws -> User {
        guard let user = try User.makeQuery()
            .join(User.TokenType.self)
            .filter(User.TokenType.self, tokenKey, token.string)
            .first()
            else {
                throw AuthenticationError.invalidCredentials
        }

        let jwt = try JWT(token: token.string)

        do { try jwt.verifyClaims([ExpirationTimeClaim(createTimestamp: { return Int(Date().timeIntervalSince1970) })]) }
        catch { throw Abort(Status.unauthorized, reason: "Your auth token has expired", identifier: ErrorIdentifiers.Authentication.tokenExpired) }

        do { try jwt.verifyClaims([SubjectClaim(string: "\(user.id?.wrapped.string ?? "")")]) }
        catch { throw Abort(Status.unauthorized, reason: "Invalid token", identifier: ErrorIdentifiers.Authentication.tokenInvalid) }

        return user
    }
}

