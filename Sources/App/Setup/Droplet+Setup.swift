@_exported import Vapor

extension Droplet {
    public func setup() throws {
        User.database = self.database
        AuthToken.database = self.database
        CalorieEntry.database = self.database
        
        let builder = Routes(jwtSecret: config["app", "jwtSecret"]!.string!)
        try builder.build(self)
    }
}
