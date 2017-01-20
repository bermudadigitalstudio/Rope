import Rope
import Foundation

struct TestCredentials {

    /// Passes database credentials in the order:
    /// environment variables, build arguments, default values
    static func getCredentials() -> RopeCredentials {

        // used if no credentials were set in ENV vars or build args
        let defaultCredentials = RopeCredentials(host: "localhost",
                                                 port: 5432,
                                                 dbName: "rope",
                                                 user: "postgres",
                                                 password: "")

        if let envCredentials = readEnvironment() {
            return envCredentials
        } else {
            // maybe the credentials were given as build args
            if let buildCredentials = readArguments() {
                return buildCredentials
            }
        }
        return defaultCredentials
    }

    /// provides database credentials unsing environment variables
    private static func readEnvironment() -> RopeCredentials? {
        guard let host = ProcessInfo().environment["DATABASE_HOST"],
            let port = ProcessInfo().environment["DATABASE_PORT"],
            let dbName = ProcessInfo().environment["DATABASE_NAME"],
            let user = ProcessInfo().environment["DATABASE_USER"],
            let password = ProcessInfo().environment["DATABASE_PASSWORD"]
        else {
            return nil
        }

        return RopeCredentials(host: host, port: Int(port)!, dbName: dbName, user: user, password: password)
    }

    /// Passes database credentials that were provided via arguments
    private static func readArguments() -> RopeCredentials? {
        let argumentKeys = ["DATABASE_HOST", "DATABASE_PORT", "DATABASE_NAME", "DATABASE_USER", "DATABASE_PASSWORD"]

        let creds = ProcessInfo().arguments.filter {
            let key = $0.components(separatedBy: "=").first! // get key, value of each argument
            return argumentKeys.contains(key) // get only the required elements
        }.map {
            $0.components(separatedBy: "=") //
        }.reduce([String: String]()) { list, components in // convert 'key=value' into a dictionary
            var result = list
            result[components[0]] = components[1]
            return result
        }

        guard let host = creds["DATABASE_HOST"],
            let port = creds["DATABASE_PORT"],
            let dbName = creds["DATABASE_NAME"],
            let user = creds["DATABASE_USER"],
            let password = creds["DATABASE_PASSWORD"]
        else {
            return nil
        }

        return RopeCredentials(host: host, port: Int(port)!, dbName: dbName, user: user, password: password)
    }
}
