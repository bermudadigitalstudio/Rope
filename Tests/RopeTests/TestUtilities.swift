import Foundation

// Provides an alternative of using the + string operator
public extension String {
    init(_ lines: String...) {
        self = ""
        
        for str in lines {
            self += "\(str) "
        }
    }
}
