#if os(Linux)
    @_exported import RopeLinux
#else
    @_exported import RopeMacOS
#endif

public enum RopeValueType: Int {
    case unsupported = -1, bool = 16, int64 = 20, int16 = 21, int32 = 23, text = 25, float = 700, double = 701, varchar = 1043
}

public final class RopeResult {

    private(set) var res: OpaquePointer? = OpaquePointer(bitPattern: 0)

    public var rowsCount: Int {
        return Int(PQntuples(self.res))
    }

    public var columnsCount: Int {
        return Int(PQnfields(self.res))
    }

    init(_ res: OpaquePointer?) {
        self.res = res
    }

    deinit {
        try? close()
    }

    public func rows() -> [Any?] {
        var rows = [Any?]()

        for rowIndex in 0 ..< rowsCount {
            let row = self.row(rowIndex)
            rows.append(row)
        }

        return rows
    }

    public func row(_ rowIndex: Int) -> [String: Any?]? {
        var columns = [String: Any?]()

        for columnIndex in 0 ..< columnsCount {
            let idx = Int32(columnIndex)

            let column = columnAt(rowIndex: Int32(rowIndex), columnIndex: idx)

            let name = String(cString: PQfname(self.res, idx))
            columns[name] = column
        }

        return columns
    }

    public func row(_ rowIndex: Int, columnName: String) -> Any? {
        guard let row = row(rowIndex), let column = row[columnName] else {
            return nil
        }

        return column
    }

    private func columnAt(rowIndex: Int32, columnIndex: Int32) -> Any? {
        guard PQgetisnull(self.res, rowIndex, columnIndex) == 0 else {
            return nil
        }

        guard let value = PQgetvalue(self.res, rowIndex, columnIndex) else {
            return nil
        }

        return convertValue(value: value, columnIndex: columnIndex)
    }

    private func convertValue(value: UnsafeMutablePointer<Int8>, columnIndex: Int32) -> Any? {
        let oid = PQftype(self.res!, Int32(columnIndex))

        guard let stringValue = String(validatingUTF8: value),
            let type = RopeValueType(rawValue: Int(oid))
        else {
            return nil
        }

        switch type {
        case .bool:
            return UnsafePointer<Bool>(OpaquePointer(value))
        case .int64:
            return Int64(stringValue)
        case .int16:
            return Int16(stringValue)
        case .int32:
            return Int32(stringValue)
        case .float:
            return Float(stringValue)
        case .double:
            return Double(stringValue)
        case .text, .varchar:
            return String(cString: value)
        default:
            return nil
        }
    }

    private func close() throws {
        guard let res = res else {
            return
        }

        PQclear(res)
        self.res = OpaquePointer(bitPattern: 0)
    }
}
