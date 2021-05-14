import CSwiftIO


 public final class I2SOut {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private var config = swift_i2s_cfg_t()

    private var mode: Mode {
        willSet {
            switch newValue {
                case .philips:
                config.mode = SWIFT_I2S_MODE_PHILIPS
                case .rightJustified:
                config.mode = SWIFT_I2S_MODE_RIGHT_JUSTIFIED
                case .leftJustified:
                config.mode = SWIFT_I2S_MODE_LEFT_JUSTIFIED
            }
        }
    }

    private var sampleChannel: SampleChannel {
        willSet {
            switch newValue {
                case .stereo:
                config.channel_type = SWIFT_I2S_CHAN_STEREO
                case .monoRight:
                config.channel_type = SWIFT_I2S_CHAN_MONO_RIGHT
                case .monoLeft:
                config.channel_type = SWIFT_I2S_CHAN_MONO_LEFT
            }
        }
    }

    private var sampleBits: Int {
        get {
            Int(config.sample_bits)
        }
        set {
            config.sample_bits = Int32(newValue)
        }
    }

    private var sampleRate: Int {
        get {
            Int(config.sample_rate)
        }
        set {
            config.sample_rate = Int32(newValue)
        }
    }

    public let supportedSampleBits: Set = [
        8, 16, 24, 32
    ]

    public let supportedSampleRate: Set = [
        8_000,
        11_025,
        12_000,
        16_000,
        22_050,
        24_000,
        32_000,
        44_100,
        48_000,
        96_000,
        192_000,
        384_000
    ]

    public init(_ idName: IdName,
                rate: Int = 24_000,
                bits: Int = 16,
                channel: SampleChannel = .monoLeft,
                mode: Mode = .philips) {
        guard supportedSampleRate.contains(rate) else {
            fatalError("The specified sampleRate \(rate) is not supported!")
        }
        guard supportedSampleBits.contains(bits) else {
            fatalError("The specified sampleBits \(bits) is not supported!")
        }
        self.id = idName.value
        self.mode = mode
        self.sampleChannel = channel
        config.sample_bits = Int32(bits)
        config.sample_rate = Int32(rate)
        switch channel {
            case .stereo:
            config.channel_type = SWIFT_I2S_CHAN_STEREO
            case .monoRight:
            config.channel_type = SWIFT_I2S_CHAN_MONO_RIGHT
            case .monoLeft:
            config.channel_type = SWIFT_I2S_CHAN_MONO_LEFT
        }
        switch mode {
            case .philips:
            config.mode = SWIFT_I2S_MODE_PHILIPS
            case .rightJustified:
            config.mode = SWIFT_I2S_MODE_RIGHT_JUSTIFIED
            case .leftJustified:
            config.mode = SWIFT_I2S_MODE_LEFT_JUSTIFIED
        }

        if let ptr = swifthal_i2s_open(id, &config, nil) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("I2SOut\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_i2s_close(obj)
    }

    public func setSampleProperty(rate: Int, bits: Int, channel: SampleChannel) {
        guard supportedSampleRate.contains(rate) else {
            fatalError("The specified sampleRate \(rate) is not supported!")
        }
        guard supportedSampleBits.contains(bits) else {
            fatalError("The specified sampleBits \(bits) is not supported!")
        }

        self.sampleBits = bits
        self.sampleRate = rate
        self.sampleChannel = channel

        if swifthal_i2s_config_set(obj, &config, nil) != 0 {
            print("I2SOut\(id) configeration failed!")
        }
    }

    public func write(_ sample: UnsafeMutableBufferPointer<UInt8>, count: Int? = nil) {
        if let count = count {
            swifthal_i2s_write(obj, sample.baseAddress!, Int32(count), -1)
        } else {
            swifthal_i2s_write(obj, sample.baseAddress!, Int32(sample.count), -1)
        }
    }


}

extension I2SOut {
    public enum Mode {
        case philips
        case rightJustified
        case leftJustified
    }

    public enum SampleChannel {
        case stereo
        case monoRight
        case monoLeft
    }
}
