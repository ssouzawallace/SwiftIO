import CSwiftIO

public func createThread(_ deadloop: @escaping swifthal_task, priority: Int) {
    swifthal_os_task_create(deadloop, nil, nil, nil, Int32(priority))
}

public func yield() {
    swifthal_os_task_yield()
}