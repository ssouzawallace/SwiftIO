/**
 I2C is a two wire serial protocol for communicating between devices.
 

 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 func main() {
 //Create a i2c bus to .I2C0
 let i2c = I2C(.I2C0)
 
    while true {

    }
 }
 ````
 
 */
 public class I2C {

    private var obj: I2CObject

    private let id: Id
    private var speed: Speed {
        willSet {
            obj.speed = newValue.rawValue
        }
    }

    private func objectInit() {
        obj.id = id.rawValue
        obj.speed = speed.rawValue
        swiftHal_i2cInit(&obj)
    }

    public init(_ id: Id,
                speed: Speed = .standard) {
        self.id = id
        self.speed = speed
        obj = I2CObject()
        objectInit()
    }

    deinit {
        swiftHal_i2cDeinit(&obj)
    }

    public func getSpeed() -> Speed {
        return speed
    }

    public func setSpeed(_ speed: Speed) {
        self.speed = speed
        swiftHal_i2cConfig(&obj)
    }

    public func readByte(from address: UInt8) -> UInt8 {
        var data = [UInt8](repeating: 0, count: 1)
        
        swiftHal_i2cRead(&obj, address, &data, 1)
        return data[0]
    }


    public func read(count: Int, from address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        swiftHal_i2cRead(&obj, address, &data, UInt32(count))
        return data
    }

    public func write(_ value: UInt8, to address: UInt8) {
        var data = [UInt8](repeating: 0, count: 1)

        data[0] = value
        swiftHal_i2cWrite(&obj, address, data, 1)
    }

    public func write(_ value: [UInt8], to address: UInt8) {
        swiftHal_i2cWrite(&obj, address, value, UInt32(value.count))
    }

    public func writeRead(_ value: [UInt8], readCount: Int, address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating:0, count: readCount)

        swiftHal_i2cWriteRead(&obj, address, value, UInt32(value.count), &data, UInt32(readCount))
        return data
    }

}

extension I2C {

    public enum Id: UInt8 {
        case I2C0, I2C1
    }

    public enum Speed: UInt32 {
        case standard = 100000, fast = 400000, fastPlus = 1000000
    }
}