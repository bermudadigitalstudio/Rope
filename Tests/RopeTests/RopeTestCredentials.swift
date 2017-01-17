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

    static func getCredentials() -> RopeCredentials? {
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
}
