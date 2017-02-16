#if os(Linux)
    @_exported import RopeLinux
#else
    @_exported import RopeMacOS
#endif

import Dispatch
import struct Foundation.UUID

public enum RopeError: Error {
    case connectionFailed(message: String)
    case emptyQuery
    case invalidQuery(message: String)
    case fatalError(message: String)
}

/// connection details to database
public struct RopeCredentials {

    private(set) public var host: String
    private(set) public var port: Int
    private(set) public var dbName: String
    private(set) public var user: String
    private(set) public var password: String

    public init(host: String, port: Int, dbName: String, user: String, password: String) {
        self.host = host
        self.port = port
        self.dbName = dbName
        self.user = user
        self.password = password
    }
}

public final class Rope {

    private(set) var conn: OpaquePointer!
    private let connectionQueue: DispatchQueue = DispatchQueue(label: "com.rope.connection-queue-\(UUID().uuidString)")

    public var connected: Bool {
        guard let conn = conn, PQstatus(conn) == CONNECTION_OK else {
            return false
        }
        return true
    }

    deinit {
        try? close()
    }

    /// connect to database using RopeCredentials struct
    public static func connect(credentials: RopeCredentials) throws -> Rope {
        let rope = Rope()
        try rope.establishConnection(host: credentials.host, port: credentials.port,
                                     dbName: credentials.dbName, user: credentials.user, password: credentials.password)

        return rope
    }

    /// connect to database using credential connection arguments
    public static func connect(host: String = "localhost", port: Int = 5432,
                               dbName: String, user: String, password: String) throws -> Rope {
        let rope = Rope()
        try rope.establishConnection(host: host, port: port, dbName: dbName, user: user, password: password)

        return rope
    }

    private func establishConnection(host: String, port: Int, dbName: String, user: String, password: String) throws {
        let conn = PQsetdbLogin(host, String(port), "", "", dbName, user, password)

        guard PQstatus(conn) == CONNECTION_OK else {
            throw failWithError(conn)
        }

        self.conn = conn
    }

    /// query database with SQL statement
    public func query(_ statement: String) throws -> RopeResult {
        return try execQuery(statement: statement)
    }

    /// query database with SQL statement, use $1, $2, etc. for params in SQL
    public func query(statement: String, params: [Any]) throws -> RopeResult {
        return try execQuery(statement: statement, params: params)
    }

    public func executePreparedStatement(named name: String, params: Any...) throws -> RopeResult {
        return try withLibPQStyleParamValues(params: params) { paramValues in
            let result = PQexecPrepared(
                self.conn,
                name,
                Int32(params.count),
                paramValues,
                nil,    // "The array pointer can be null when there are no binary parameters."
                nil,    // "If the array pointer is null then all parameters are presumed to be text strings."
                0       // "Specify zero to obtain results in text format"
            )
            guard let res = result else {
                throw failWithError()
            }
            return try validateQueryResultStatus(res)
        }
    }

    private func execQuery(statement: String, params: [Any]? = nil) throws -> RopeResult {
        if statement.isEmpty {
            throw RopeError.emptyQuery
        }

        guard let params = params else {
            let result = self.connectionQueue.sync {
                return PQexec(self.conn, statement)
            }
            
            guard let res = result else {
                throw failWithError()
            }

            return try validateQueryResultStatus(res)
        }

        return try withLibPQStyleParamValues(params: params) { values in
            let result = self.connectionQueue.sync {
                return PQexecParams(self.conn, statement, Int32(params.count), nil, values, nil, nil, Int32(0))
            }
            guard let res = result else {
                throw failWithError()
            }

            return try validateQueryResultStatus(res)
        }
    }

    private func withLibPQStyleParamValues<T>(params: [Any], _ closure: (UnsafeMutablePointer<UnsafePointer<Int8>?>) throws -> T) rethrows -> T {
        let paramsCount = params.count
        let values = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: paramsCount)
        defer {
            values.deallocate(capacity: paramsCount)
        }
        var tempValues = [Array<UInt8>]()
        for (idx, value) in params.enumerated() {

            let s = String(describing: value).utf8

            tempValues.append(Array<UInt8>(s) + [0])
            values[idx] = UnsafePointer<Int8>(OpaquePointer(tempValues.last!))
        }
        return try closure(values)
    }

    func validateQueryResultStatus(_ res: OpaquePointer) throws -> RopeResult {
        switch PQresultStatus(res) {
        case PGRES_COMMAND_OK, PGRES_TUPLES_OK:
            return RopeResult(res)
        case PGRES_FATAL_ERROR:
            let message = String(cString: PQresultErrorMessage(res))
            throw RopeError.fatalError(message: message)
        default:
            let message = String(cString: PQresultErrorMessage(res))
            throw RopeError.invalidQuery(message: message)
        }
    }

    private func close() throws {
        guard self.connected else {
            throw failWithError()
        }

        PQfinish(conn)
        conn = nil
    }

    private func failWithError(_ conn: OpaquePointer? = nil) -> Error {
        let message = String(cString: PQerrorMessage(conn ?? self.conn))
        return RopeError.connectionFailed(message: message)
    }
}
