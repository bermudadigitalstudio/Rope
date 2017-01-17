//
//  Secrets.swift
//  Rope
//
//  Created by Sebastian Kreutzberger on 1/16/17.
//
//

import Rope
import Foundation

struct TestCredentials {

    /// Passes database credentials that are provided as environment variables.
    static func getCredentials() -> RopeCredentials? {
        // check if creadentials are passed as environment variables
        guard let creds = readEnvironment() else {
            // check if creadentials are passed as build arguements, otherwise return nil
            return readArguments()
        }
        return creds
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
    
    /// Passes database credentials that were provided via arguments.
    private static func readArguments() -> RopeCredentials? {
        let argumentKeys = ["DATABASE_HOST", "DATABASE_PORT", "DATABASE_NAME", "DATABASE_USER", "DATABASE_PASSWORD"]
        
        let creds = ProcessInfo().arguments.filter {
            let key = $0.components(separatedBy: "=").first!
            return argumentKeys.contains(key)
        }.map {
            $0.components(separatedBy: "=")
        }.reduce([String:String]()) { list, components in
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
