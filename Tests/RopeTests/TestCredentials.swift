import Rope
import Foundation

struct TestCredentials {

    /// Passes database credentials in the order:
    /// environment variables, build arguments, default values
    static func getCredentials() -> RopeCredentials {
        if let envCredentials = readEnvironment() {
            return envCredentials
        } else if let buildArgsCredentials = readArguments() {
            // maybe the credentials were given as build args
            return buildArgsCredentials
        }

        // used if no credentials were set in ENV vars or build args
        return RopeCredentials(host: "localhost", port: 5432, dbName: "postgres", user: "postgres", password: "")
    }

    static var processArgs: [String:String] {
        let argumentKeys = ["DATABASE_HOST", "DATABASE_PORT", "DATABASE_NAME", "DATABASE_USER", "DATABASE_PASSWORD"]
        let creds = ProcessInfo.processInfo.arguments.filter {
            let key = $0.components(separatedBy: "=").first! // get key, value of each argument
            return argumentKeys.contains(key) // get only the required elements
            }.map {
                $0.components(separatedBy: "=") //
            }.reduce([String: String]()) { list, components in // convert 'key=value' into a dictionary
                var result = list
                result[components[0]] = components[1]
                return result
        }
        return creds
    }

    /// provides database credentials unsing environment variables
    private static func readEnvironment() -> RopeCredentials? {
        guard let host = ProcessInfo.processInfo.environment["DATABASE_HOST"],
            let portEnv = ProcessInfo.processInfo.environment["DATABASE_PORT"], let port = Int(portEnv),
            let dbName = ProcessInfo.processInfo.environment["DATABASE_NAME"],
            let user = ProcessInfo.processInfo.environment["DATABASE_USER"],
            let password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"]
        else {
            return nil
        }

        return RopeCredentials(host: host, port: port, dbName: dbName, user: user, password: password)
    }

    /// Passes database credentials that were provided via arguments
    private static func readArguments() -> RopeCredentials? {
        let creds = processArgs
        guard let host = creds["DATABASE_HOST"],
            let portEnv = creds["DATABASE_PORT"], let port = Int(portEnv),
            let dbName = creds["DATABASE_NAME"],
            let user = creds["DATABASE_USER"],
            let password = creds["DATABASE_PASSWORD"]
        else {
            return nil
        }

        return RopeCredentials(host: host, port: port, dbName: dbName, user: user, password: password)
    }
}
