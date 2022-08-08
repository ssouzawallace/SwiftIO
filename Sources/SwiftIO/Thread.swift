import CSwiftIO

public func createThread(_ deadloop: @escaping swifthal_task, priority: Int) {
    swifthal_os_task_create(deadloop, nil, nil, nil, Int32(priority))
}

public func yield() {
    swifthal_os_task_yield()
}


public struct Mutex {
    let mutex: UnsafeMutableRawPointer

    public init() {
        mutex = swifthal_os_mutex_create()
    }

    @discardableResult
    public func lock(_ timeout: Int = -1) -> Result<(), Errno> {
        return nothingOrErrno(
            swifthal_os_mutex_lock(mutex, Int32(timeout))
        )
    }

    @discardableResult
    public func unlock() -> Result<(), Errno> {
        return nothingOrErrno(
            swifthal_os_mutex_unlock(mutex)
        )
    }

    public func destroy() {
        swifthal_os_mutex_destroy(mutex)
    }
}




public struct MessageQueue {
    let queue: UnsafeMutableRawPointer

    public init(maxMessageBytes: Int, maxMessageCount: Int) {
        queue = swifthal_os_mq_create(Int32(maxMessageBytes), Int32(maxMessageCount))
    }

    public func destroy() {
        swifthal_os_mq_destory(queue)
    }

    @discardableResult
    public func send(data: UnsafeMutableRawPointer, timeout: Int = -1) -> Result<(), Errno> {
        return nothingOrErrno(
            swifthal_os_mq_send(queue, data, Int32(timeout))
        )
    }

    @discardableResult
    public func receive(into data: UnsafeMutableRawPointer, timeout: Int = -1) -> Result<(), Errno> {
        return nothingOrErrno(
            swifthal_os_mq_recv(queue, data, Int32(timeout))
        )
    }

    // public func peek(into data: UnsafeMutableRawPointer) {
    //     swifthal_os_mq_peek(queue, data)
    // }

    public func purge() {
        swifthal_os_mq_purge(queue)
    }
}