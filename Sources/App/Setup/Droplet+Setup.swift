@_exported import Vapor

extension Droplet {
    public func setup() throws {
        let builder = Routes(jwtSecret: config["app", "jwtSecret"]!.string!)
        try builder.build(self)
        
        database?.log = { query in
            print(query.description)
        }
    }
}
