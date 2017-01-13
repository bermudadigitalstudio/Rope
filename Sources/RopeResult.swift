#if os(Linux)
    @_exported import RopeLinux
#else
    @_exported import RopeMacOS
#endif


public final class RopeResult {

    private(set) var res: OpaquePointer? = OpaquePointer(bitPattern: 0)

    init(_ res: OpaquePointer?) {
        self.res = res
    }

    deinit {
        try? close()
    }

    private func close() throws {
        guard let res = res else {
            return
        }

        PQclear(res)
    }
}
