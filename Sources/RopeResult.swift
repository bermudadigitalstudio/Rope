#if os(Linux)
    @_exported import RopeLinux
#else
    @_exported import RopeMacOS
#endif

import Foundation

public enum RopeValueType: Int {
    case unsupported = -1, bool = 16, int64 = 20, int16 = 21, int32 = 23, text = 25, float = 700, double = 701, char = 1042, varchar = 1043, date = 1082, timestamp = 1114
}

public final class RopeResult {

    private(set) var result: OpaquePointer? = OpaquePointer(bitPattern: 0)

    public var rowsCount: Int {
        return Int(PQntuples(self.result))
    }

    public var columnsCount: Int {
        return Int(PQnfields(self.result))
    }

    init(_ res: OpaquePointer?) {
        self.result = res
    }

    deinit {
        try? close()
    }

    public func rows() -> [[String: Any?]] {
        var rows = [[String: Any?]]()

        for rowIndex in 0 ..< rowsCount {
            let row = self.row(rowIndex)
            rows.append(row)
        }

        return rows
    }

    private func row(_ rowIndex: Int) -> [String: Any?] {
        var columns = [String: Any?]()

        for columnIndex in 0 ..< columnsCount {
            let idx = Int32(columnIndex)

            guard let column = columnAt(rowIndex: Int32(rowIndex), columnIndex: idx) else {
                continue
            }

            let name = String(cString: PQfname(self.result, idx))
            columns[name] = column
        }

        return columns
    }

    private func columnAt(rowIndex: Int32, columnIndex: Int32) -> Any? {
        guard PQgetisnull(self.result, rowIndex, columnIndex) == 0 else {
            return nil
        }

        guard let value = PQgetvalue(self.result, rowIndex, columnIndex) else {
            return nil
        }

        return convertValue(value: value, columnIndex: columnIndex)
    }

    private func convertValue(value: UnsafeMutablePointer<Int8>, columnIndex: Int32) -> Any? {
        let oid = PQftype(self.result!, Int32(columnIndex))

        guard let stringValue = String(validatingUTF8: value),
            let type = RopeValueType(rawValue: Int(oid))
        else {
            return nil
        }

        switch type {
        case .bool:
            return String(cString: value) == "t"
        case .int16, .int32, .int64:
            return Int(stringValue)
        case .float, .double:
            return Float(stringValue)
        case .text, .char, .varchar:
            return stringValue
        case .date, .timestamp:
            let date = convertDateValue(stringValue, valueType: type)
            return date
        default:
            return nil
        }
    }

    private func convertDateValue(_ dateString: String, valueType: RopeValueType) -> Date? {
        let (format, respectUTC) = { (valueType: RopeValueType) -> (String, Bool) in
            switch valueType {
            case .timestamp:
                return ("yyyy-MM-dd HH:mm:ss.SSS", true)
            default:
                return ("yyyy-MM-dd", false)
            }
        }(valueType)

        let formatter = DateFormatter()
        if respectUTC {
            formatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        formatter.dateFormat = format

        return formatter.date(from: dateString)
    }

    private func close() throws {
        guard let res = result else {
            return
        }

        PQclear(res)
        self.result = OpaquePointer(bitPattern: 0)
    }
}
