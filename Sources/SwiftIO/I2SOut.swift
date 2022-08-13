//=== I2SOut.swift --------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/// The I2SOut class is used to send out audio data to external audio devices.
///
/// I2S is a serial protocol to transmit audio data between devices. I2S needs
/// three wires for communication:
/// - SCK (Serial clock): or Bit Clock (BCLK), it carries the clock signal.
/// - FS (Frame Sync): or Word Select (WS), it tells that the audio data is for
/// the right or left channel.
/// - SD (Serial data): it is used to transfer audio data.
///
/// The I2SOut class is used to send audio data to other audio devices, like speakers.
/// So the data line carries the audio data send to external devices. For data input,
/// you can use ``I2SIn`` instead.
///
/// You can initialize an I2SOut instance using the default setting as below:
///
/// ```swift
/// let i2s = I2SOut(Id.I2SOut0)
/// ```
/// The I2SOut0 corresponds the pins BCLK0, SYNC0 and TX0 on your board.
///
/// During initialization, you should match the sample rate, sample bits and
/// channel settings with the audio info. The clock frequency equals
/// _Sample Rate x Bits per channel x Number of channels_.
 public final class I2SOut {
    private let id: Int32
    public let obj: UnsafeMutableRawPointer

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

    public init(
        _ idName: IdName,
        rate: Int = 16_000,
        bits: Int = 16,
        channel: SampleChannel = .monoLeft,
        mode: Mode = .philips
    ) {
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


        if let ptr = swifthal_i2s_handle_get(id) {
            obj = UnsafeMutableRawPointer(ptr)
        } else if let ptr = swifthal_i2s_open(id) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("I2SOut\(idName.value) initialization failed!")
        }

        swifthal_i2s_tx_config_set(obj, &config)
        swifthal_i2s_tx_status_set(obj, 1)
    }

    deinit {
        swifthal_i2s_tx_status_set(obj, 0)
        if swifthal_i2s_rx_status_get(obj) == 0 {
            swifthal_i2s_close(obj)
        }
    }

    public func setSampleProperty(
        rate: Int, bits: Int, channel: SampleChannel
    ) {
        guard supportedSampleRate.contains(rate) else {
            fatalError("The specified sampleRate \(rate) is not supported!")
        }
        guard supportedSampleBits.contains(bits) else {
            fatalError("The specified sampleBits \(bits) is not supported!")
        }

        self.sampleBits = bits
        self.sampleRate = rate
        self.sampleChannel = channel

        if swifthal_i2s_tx_config_set(obj, &config) != 0 {
            print("I2SOut\(id) configeration failed!")
        }
    }

    public func write(
        _ sample: [UInt8],
        count: Int? = nil,
        timeout: Int? = nil
    ) {
        let timeoutValue: Int32

        var writeLength = 0
        var result = validateLength(sample, count: count, length: &writeLength)

        if let timeout = timeout {
            timeoutValue = Int32(timeout)
        } else {
            timeoutValue = Int32(SWIFT_FOREVER)
        }

        if case .success = result {
            result = nothingOrErrno(
                swifthal_i2s_write(obj, sample, Int32(writeLength), timeoutValue)
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
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
