#if os(Linux)
    @_exported import RopeLinux
#else
    @_exported import RopeMacOS
#endif

public enum RopeError: Error {
    case connectionFailed(message: String)
}

public final class Rope {

    private(set) var conn: OpaquePointer!

    public var connected: Bool {
        guard let conn = conn, PQstatus(conn) == CONNECTION_OK else {
            return false
        }
        return true
    }

    deinit {
        try? close()
    }

    public static func connect(host: String = "localhost", port: Int = 5432, dbName: String, user: String, password: String) throws -> Rope {
        let rope = Rope()
        try rope.establishConnection(host: host, port: port, dbName: dbName, user: user, password: password)

        return rope
    }

    private func establishConnection(host: String, port: Int, dbName: String, user: String, password: String) throws {
        let conn = PQsetdbLogin(host, String(port), "", "", dbName, user, password)

        guard PQstatus(conn) == CONNECTION_OK else {
            try failWithError(conn); return
        }

        self.conn = conn
    }

    public func query(_ statement: String) {
    }

    public func query(statement: String, params: [Any]) {
    }

    public func close() throws {
        guard self.connected else {
            try failWithError(); return
        }

        PQfinish(conn)
        conn = nil
    }

    private func failWithError(_ conn: OpaquePointer? = nil) throws {
        let message = String(cString: PQerrorMessage(conn ?? self.conn))
        throw RopeError.connectionFailed(message: message)
    }
}