//
//  SoundManager.swift
//  Catalittle
//
//  Rock-solid audio synthesizer and player for Bearalot.
//  Synthesizes shimmering Glockenspiel / Bell chimes, bubble pops,
//  and a crowned 16x+ Prestige Glockenspiel Chime with sparkling resonance.
//

import Foundation
import AVFoundation

class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    
    private var popPlayers: [AVAudioPlayer] = []
    private var popPlayerIndex = 0
    
    private var selectPlayer: AVAudioPlayer?
    private var errorPlayer: AVAudioPlayer?
    private var comboPlayers: [AVAudioPlayer] = []
    private var prestigePlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        setupAudioSession()
        prepareSoundEffects()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup warning: \(error)")
        }
        #endif
    }
    
    private func prepareSoundEffects() {
        let sampleRate: Double = 44100.0
        let tempDir = FileManager.default.temporaryDirectory
        
        // 1. Generate Bubble Pop WAV
        let popData = generatePopWAVData(sampleRate: sampleRate)
        let popURL = tempDir.appendingPathComponent("bearalot_pop.wav")
        try? popData.write(to: popURL)
        
        for _ in 0..<6 {
            if let player = try? AVAudioPlayer(contentsOf: popURL) {
                player.prepareToPlay()
                popPlayers.append(player)
            }
        }
        
        // 2. Generate Tap Select WAV
        let selectData = generateTapWAVData(sampleRate: sampleRate)
        let selectURL = tempDir.appendingPathComponent("bearalot_select.wav")
        try? selectData.write(to: selectURL)
        if let player = try? AVAudioPlayer(contentsOf: selectURL) {
            player.prepareToPlay()
            selectPlayer = player
        }
        
        // 3. Generate Error WAV
        let errorData = generateErrorWAVData(sampleRate: sampleRate)
        let errorURL = tempDir.appendingPathComponent("bearalot_error.wav")
        try? errorData.write(to: errorURL)
        if let player = try? AVAudioPlayer(contentsOf: errorURL) {
            player.prepareToPlay()
            errorPlayer = player
        }
        
        // 4. Generate Shimmering Glockenspiel / Bell Chimes (1x to 15x)
        let frequencies: [Double] = [
            523.25,  // C5 (1x)
            587.33,  // D5 (2x)
            659.25,  // E5 (3x)
            698.46,  // F5 (4x)
            783.99,  // G5 (5x)
            880.00,  // A5 (6x)
            987.77,  // B5 (7x)
            1046.50, // C6 (8x)
            1174.66, // D6 (9x)
            1318.51, // E6 (10x)
            1396.91, // F6 (11x)
            1567.98, // G6 (12x)
            1760.00, // A6 (13x)
            1975.53, // B6 (14x)
            2093.00  // C7 (15x)
        ]
        
        for (i, freq) in frequencies.enumerated() {
            let bellData = generateGlockenspielBellWAVData(frequency: freq, sampleRate: sampleRate)
            let bellURL = tempDir.appendingPathComponent("bearalot_bell_\(i).wav")
            try? bellData.write(to: bellURL)
            if let player = try? AVAudioPlayer(contentsOf: bellURL) {
                player.prepareToPlay()
                comboPlayers.append(player)
            }
        }
        
        // 5. Generate Crowned Prestige Glockenspiel WAV (16x+)
        let prestigeData = generatePrestigeGlockenspielWAVData(sampleRate: sampleRate)
        let prestigeURL = tempDir.appendingPathComponent("bearalot_prestige.wav")
        try? prestigeData.write(to: prestigeURL)
        if let player = try? AVAudioPlayer(contentsOf: prestigeURL) {
            player.prepareToPlay()
            prestigePlayer = player
        }
    }
    
    // MARK: - Playback Methods
    
    func playPop() {
        guard !popPlayers.isEmpty else { return }
        let player = popPlayers[popPlayerIndex]
        popPlayerIndex = (popPlayerIndex + 1) % popPlayers.count
        player.currentTime = 0
        player.play()
    }
    
    func playCombo(index: Int) {
        if index >= 16 {
            // Crowned Prestige Glockenspiel for 16x+
            prestigePlayer?.currentTime = 0
            prestigePlayer?.play()
        } else {
            guard !comboPlayers.isEmpty else { return }
            let clampedIndex = max(0, min(index - 1, comboPlayers.count - 1))
            let player = comboPlayers[clampedIndex]
            player.currentTime = 0
            player.play()
        }
    }
    
    func playSelect() {
        selectPlayer?.currentTime = 0
        selectPlayer?.play()
    }
    
    func playError() {
        errorPlayer?.currentTime = 0
        errorPlayer?.play()
    }
    
    // MARK: - Procedural Sound Synthesizers
    
    /// Bubbly Pop
    private func generatePopWAVData(sampleRate: Double) -> Data {
        let duration: Double = 0.085
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)
        var phase: Double = 0.0
        
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let progress = t / duration
            let freq = 1150.0 * (1.0 - progress * 0.80)
            phase += 2.0 * .pi * freq / sampleRate
            let envelope = exp(-progress * 8.5) * sin(progress * .pi)
            let sampleVal = sin(phase) * envelope * 0.90
            samples[i] = Int16(max(-32767, min(32767, sampleVal * 32767)))
        }
        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }
    
    /// Shimmering Glockenspiel / Bell
    private func generateGlockenspielBellWAVData(frequency: Double, sampleRate: Double) -> Data {
        let duration: Double = 0.50
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)
        
        var phase1: Double = 0.0
        var phase2: Double = 0.0
        var phase3: Double = 0.0
        var phase4: Double = 0.0
        
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let progress = t / duration
            
            phase1 += 2.0 * .pi * frequency / sampleRate
            phase2 += 2.0 * .pi * (frequency * 2.756) / sampleRate
            phase3 += 2.0 * .pi * (frequency * 5.404) / sampleRate
            phase4 += 2.0 * .pi * (frequency * 8.933) / sampleRate
            
            let env1 = exp(-progress * 5.5)
            let env2 = exp(-progress * 11.0) * 0.45
            let env3 = exp(-progress * 20.0) * 0.22
            let env4 = exp(-progress * 35.0) * 0.15
            
            let shimmer = 1.0 + 0.05 * sin(2.0 * .pi * 6.0 * t)
            let sampleVal = (sin(phase1) * env1 + sin(phase2) * env2 + sin(phase3) * env3 + sin(phase4) * env4) * shimmer * 0.85
            samples[i] = Int16(max(-32767, min(32767, sampleVal * 32767)))
        }
        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }
    
    /// Crowned 16x+ Prestige Glockenspiel Sound (Glockenspiel Lead C7 + Harmonic Sparkle Chime)
    private func generatePrestigeGlockenspielWAVData(sampleRate: Double) -> Data {
        let duration: Double = 0.60
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)
        
        // Lead Glockenspiel Note C7 (2093 Hz) + Supporting Harmonic Bells (C6 1046.5 Hz, G6 1568 Hz, E7 2637 Hz)
        let bellLayers: [(freq: Double, weight: Double, decay: Double)] = [
            (2093.00, 1.00, 5.0), // Lead Glockenspiel C7
            (5768.00, 0.40, 12.0), // High metallic bar overtone
            (1046.50, 0.50, 6.0), // Warm lower octave C6
            (1567.98, 0.40, 5.5), // Perfect 5th bell G6
            (2637.02, 0.35, 8.0)  // Glistening Major 3rd E7
        ]
        
        var phases = [Double](repeating: 0.0, count: bellLayers.count)
        
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            let progress = t / duration
            
            var totalBell: Double = 0.0
            for (idx, layer) in bellLayers.enumerated() {
                phases[idx] += 2.0 * .pi * layer.freq / sampleRate
                let env = exp(-progress * layer.decay)
                totalBell += sin(phases[idx]) * env * layer.weight
            }
            
            // Sparkle shimmer
            let sparkle = 1.0 + 0.08 * sin(2.0 * .pi * 8.0 * t)
            let finalVal = (totalBell / 1.8) * sparkle * 0.90
            samples[i] = Int16(max(-32767, min(32767, finalVal * 32767)))
        }
        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }
    
    private func generateTapWAVData(sampleRate: Double) -> Data {
        let duration: Double = 0.03
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)
        var phase: Double = 0.0
        
        for i in 0..<numSamples {
            let progress = Double(i) / Double(numSamples)
            phase += 2.0 * .pi * 1500.0 / sampleRate
            let env = exp(-progress * 18.0)
            let sampleVal = sin(phase) * env * 0.45
            samples[i] = Int16(max(-32767, min(32767, sampleVal * 32767)))
        }
        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }
    
    private func generateErrorWAVData(sampleRate: Double) -> Data {
        let duration: Double = 0.14
        let numSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: numSamples)
        
        for i in 0..<numSamples {
            let progress = Double(i) / Double(numSamples)
            let freq = (i < numSamples / 2) ? 180.0 : 140.0
            let phase = 2.0 * .pi * freq * (Double(i) / sampleRate)
            let env = exp(-progress * 5.0)
            let sampleVal = sin(phase) * env * 0.4
            samples[i] = Int16(max(-32767, min(32767, sampleVal * 32767)))
        }
        return createWAVFile(samples: samples, sampleRate: Int(sampleRate))
    }
    
    // MARK: - Binary WAV File Builder
    
    private func createWAVFile(samples: [Int16], sampleRate: Int) -> Data {
        var data = Data()
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate: UInt32 = UInt32(sampleRate) * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign: UInt16 = numChannels * (bitsPerSample / 8)
        let subchunk2Size: UInt32 = UInt32(samples.count * 2)
        let chunkSize: UInt32 = 36 + subchunk2Size
        
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
        let subchunk1Size: UInt32 = 16
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        let audioFormat: UInt16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        let sampleRateU32 = UInt32(sampleRate)
        data.append(contentsOf: withUnsafeBytes(of: sampleRateU32.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        data.append(contentsOf: withUnsafeBytes(of: subchunk2Size.littleEndian) { Array($0) })
        
        samples.withUnsafeBufferPointer { buffer in
            data.append(UnsafeBufferPointer(start: UnsafePointer<UInt8>(OpaquePointer(buffer.baseAddress)), count: samples.count * 2))
        }
        
        return data
    }
}
