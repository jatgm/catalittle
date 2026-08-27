//
//  SoundManager.swift
//  Catalittle
//
//  Low-latency procedural arcade sound synthesizer for Bearalot.
//  Generates bubble pops, ascending xylophone combo chimes, and tap clicks in memory.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100.0
    
    // Pre-rendered audio PCM buffers
    private var popBuffer: AVAudioPCMBuffer?
    private var selectBuffer: AVAudioPCMBuffer?
    private var errorBuffer: AVAudioPCMBuffer?
    private var comboBuffers: [AVAudioPCMBuffer] = []
    
    private init() {
        setupAudioEngine()
        generateAudioBuffers()
    }
    
    private func setupAudioEngine() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        #endif
        
        engine.attach(playerNode)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("AVAudioEngine start error: \(error)")
        }
    }
    
    private func generateAudioBuffers() {
        popBuffer = makePopSoundBuffer()
        selectBuffer = makeTapSoundBuffer()
        errorBuffer = makeErrorSoundBuffer()
        
        // Ascending Xylophone / Marimba Scale for Combos (C5, D5, E5, G5, A5, C6, D6, E6, G6)
        let comboFrequencies: [Double] = [
            523.25, // C5 (1x)
            659.25, // E5 (2x)
            783.99, // G5 (3x)
            880.00, // A5 (4x)
            1046.50, // C6 (5x)
            1174.66, // D6 (6x)
            1318.51, // E6 (7x)
            1567.98  // G6 (8x+)
        ]
        
        for freq in comboFrequencies {
            if let buf = makeXylophoneChimeBuffer(frequency: freq) {
                comboBuffers.append(buf)
            }
        }
    }
    
    // MARK: - Procedural Sound Synthesizers
    
    /// Bubble Pop: A swift downward frequency chirp with resonant bubble envelope.
    private func makePopSoundBuffer() -> AVAudioPCMBuffer? {
        let duration: Double = 0.08
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channels = buffer.floatChannelData![0]
        var phase: Double = 0.0
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let progress = t / duration
            
            // Frequency sweeps rapidly from 950 Hz down to 220 Hz
            let freq = 950.0 * (1.0 - progress * 0.75)
            phase += 2.0 * .pi * freq / sampleRate
            
            // Pluck envelope: sharp exponential decay
            let envelope = exp(-progress * 7.0) * sin(progress * .pi)
            let sample = Float(sin(phase) * envelope * 0.75)
            channels[frame] = sample
        }
        return buffer
    }
    
    /// Xylophone / Bell Chime: Rich harmonic overtone with ringing acoustic decay.
    private func makeXylophoneChimeBuffer(frequency: Double) -> AVAudioPCMBuffer? {
        let duration: Double = 0.38
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channels = buffer.floatChannelData![0]
        var phase1: Double = 0.0
        var phase2: Double = 0.0
        var phase3: Double = 0.0
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let progress = t / duration
            
            // Fundamental + 2nd Harmonic (Xylophone strike characteristics)
            phase1 += 2.0 * .pi * frequency / sampleRate
            phase2 += 2.0 * .pi * (frequency * 2.756) / sampleRate // Distinct wooden bar overtone
            phase3 += 2.0 * .pi * (frequency * 5.404) / sampleRate
            
            let env1 = exp(-progress * 8.0)
            let env2 = exp(-progress * 18.0) * 0.4
            let env3 = exp(-progress * 28.0) * 0.2
            
            let strike = (sin(phase1) * env1 + sin(phase2) * env2 + sin(phase3) * env3) * 0.8
            channels[frame] = Float(strike)
        }
        return buffer
    }
    
    /// Crisp Tap Click
    private func makeTapSoundBuffer() -> AVAudioPCMBuffer? {
        let duration: Double = 0.03
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channels = buffer.floatChannelData![0]
        var phase: Double = 0.0
        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / Double(frameCount)
            phase += 2.0 * .pi * 1200.0 / sampleRate
            let env = exp(-progress * 15.0)
            channels[frame] = Float(sin(phase) * env * 0.5)
        }
        return buffer
    }
    
    /// Error Buzz
    private func makeErrorSoundBuffer() -> AVAudioPCMBuffer? {
        let duration: Double = 0.12
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channels = buffer.floatChannelData![0]
        var phase: Double = 0.0
        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / Double(frameCount)
            phase += 2.0 * .pi * 160.0 / sampleRate
            let env = exp(-progress * 5.0) * (sin(Double(frame) * 0.05) > 0 ? 1.0 : -1.0)
            channels[frame] = Float(env * 0.35)
        }
        return buffer
    }
    
    // MARK: - Public Playback Methods
    
    func playPop() {
        guard let buf = popBuffer else { return }
        play(buffer: buf)
    }
    
    func playCombo(index: Int) {
        guard !comboBuffers.isEmpty else { return }
        let clampedIndex = max(0, min(index - 1, comboBuffers.count - 1))
        let buf = comboBuffers[clampedIndex]
        play(buffer: buf)
    }
    
    func playSelect() {
        guard let buf = selectBuffer else { return }
        play(buffer: buf)
    }
    
    func playError() {
        guard let buf = errorBuffer else { return }
        play(buffer: buf)
    }
    
    private func play(buffer: AVAudioPCMBuffer) {
        if !engine.isRunning {
            try? engine.start()
        }
        playerNode.play()
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }
}
