import RopeLibpq

import Foundation

public enum RopeJsonColumn {
    case dictionary
    case string
    case data
}

public enum RopeValueType: Int {
    case unsupported = -1

    case bool = 16

    case int16 = 21
    case int32 = 23
    case int64 = 20

    case float = 700
    case double = 701

    case char = 1042
    case varchar = 1043
    case text = 25

    case date = 1082
    case timestamp = 1114
    case timestamptz = 1184

    case numeric = 1700

    case json = 3802
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

    public func rows(jsonColumn: RopeJsonColumn = .dictionary) -> [[String: Any?]] {
        var rows = [[String: Any?]]()

        for rowIndex in 0 ..< rowsCount {
            let row = self.row(rowIndex, jsonColumn: jsonColumn)
            rows.append(row)
        }

        return rows
    }

    private func row(_ rowIndex: Int, jsonColumn: RopeJsonColumn) -> [String: Any?] {
        var columns = [String: Any?]()

        for columnIndex in 0 ..< columnsCount {
            let idx = Int32(columnIndex)

            guard let column = columnAt(rowIndex: Int32(rowIndex), columnIndex: idx, jsonColumn: jsonColumn) else {
                continue
            }

            let name = String(cString: PQfname(self.result, idx))
            columns[name] = column
        }

        return columns
    }

    private func columnAt(rowIndex: Int32, columnIndex: Int32, jsonColumn: RopeJsonColumn) -> Any? {
        guard PQgetisnull(self.result, rowIndex, columnIndex) == 0 else {
            return nil
        }

        guard let value = PQgetvalue(self.result, rowIndex, columnIndex) else {
            return nil
        }

        return convert(value: value, columnIndex: columnIndex, jsonColumn: jsonColumn)
    }

    private func convert(value: UnsafeMutablePointer<Int8>, columnIndex: Int32, jsonColumn: RopeJsonColumn) -> Any? {
        guard let result = self.result else {
            return nil
        }

        let oid = PQftype(result, Int32(columnIndex))

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
        case .numeric:
            return Decimal(string: stringValue, locale: Locale(identifier: "en_US"))
        case .text, .char, .varchar:
            return stringValue
        case .json:
            switch jsonColumn {
            case .dictionary:
                return convert(jsonValue: stringValue)
            case .string:
                return stringValue
            case .data:
                return stringValue.data(using: String.Encoding.utf8)
            }
        case .date, .timestamp, .timestamptz:
            let date = convert(dateValue: stringValue, valueType: type)
            return date
        default:
            return nil
        }
    }

    private func convert(dateValue: String, valueType: RopeValueType) -> Date? {
        let (format, respectUTC) = { (valueType: RopeValueType) -> (String, Bool) in
            switch valueType {
            case .timestamptz:
                return ("yyyy-MM-dd HH:mm:ssZ", false)
            case .timestamp:
                return ("yyyy-MM-dd HH:mm:ss.SSS", true)
            default:
                return ("yyyy-MM-dd", true)
            }
        }(valueType)

        let formatter = DateFormatter()
        if respectUTC {
            formatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        formatter.dateFormat = format

        return formatter.date(from: dateValue)
    }

    private func convert(jsonValue: String) -> [String: Any]? {
        guard let data = jsonValue.data(using: String.Encoding.utf8) else {
            return nil
        }

        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
        } catch {
            return nil
        }
    }

    private func close() throws {
        guard let res = result else {
            return
        }

        PQclear(res)
        self.result = OpaquePointer(bitPattern: 0)
    }
}
