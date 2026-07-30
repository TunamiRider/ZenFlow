//
//  WaveTick.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI
import AVPlayerPlus

//struct WaveTick: View {
//    let progress: Double
//    let secondsElapsed: Int
//    let isAnimating: Bool
//
//    private let barCount = 36
//    private let barWidth: CGFloat = 2.5
//
//    @State private var tickPulse: Double = 0
//    @State private var frozenT: Double = 0
//    @State private var amplitude: Double = 0
//    @State private var targetAmplitude: Double = 0
//
//    var body: some View {
//        TimelineView(.animation) { timeline in
//            Canvas { context, size in
//                let t = currentT(now: timeline.date)
//                let gap = (size.width - CGFloat(barCount) * barWidth) / CGFloat(barCount + 1)
//
//                for i in 0..<barCount {
//                    let x = gap + CGFloat(i) * (barWidth + gap)
//                    let h = barHeight(index: i, total: barCount, t: t, size: size)
//                    let y = size.height - h
//
//                    let barFraction = Double(x) / Double(size.width)
//                    let alpha: Double = barFraction <= progress ? 0.85 : 0.28
//
//                    let rect = CGRect(x: x, y: y, width: barWidth, height: h)
//                    let path = Path(roundedRect: rect, cornerRadius: 1.5)
//                    context.fill(path, with: .color(.white.opacity(alpha)))
//                }
//            }
//        }
//        .frame(height: 56)
//        // ✅ Lerp amplitude on main thread at ~60fps, outside Canvas
//        .task {
//            while !Task.isCancelled {
//                let step = 0.04
//                if abs(amplitude - targetAmplitude) > 0.001 {
//                    amplitude += (targetAmplitude - amplitude) * step
//                }
//                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
//            }
//        }
//        .onChange(of: secondsElapsed) { oldValue, newValue in
//            triggerTickPulse()
//        }
//        .onChange(of: isAnimating) { oldRunning, newRunning in
//            if newRunning {
//                targetAmplitude = 1
//            } else {
//                frozenT = currentT(now: Date())
//                targetAmplitude = 0
//            }
//        }
//    }
//
//    private func currentT(now: Date) -> Double {
//        isAnimating ? now.timeIntervalSinceReferenceDate : frozenT
//    }
//
//    private func barHeight(index: Int, total: Int, t: Double, size: CGSize) -> CGFloat {
//        let i = Double(index)
//        let n = Double(total)
//
//        let wave = sin(i / n * .pi * 2.0 - t * 1.2) * 0.5 + 0.5
//        let envelope = 0.5 + 0.5 * sin(i / n * .pi)
//        let peakPulse = tickPulse * exp(-tickPulse * 3.0) * 0.25
//
//        let base = 0.18
//        let height = base + wave * envelope * 0.62 * amplitude + peakPulse
//
//        return CGFloat(min(0.95, height)) * size.height
//    }
//
//    private func triggerTickPulse() {
//        tickPulse = 0
//        withAnimation(.linear(duration: 0.8)) {
//            tickPulse = 1
//        }
//    }
//}



struct WaveTick: View {
    let progress: Double
    let secondsElapsed: Int
    let isAnimating: Bool
    let settings: PlayerSettings          // ← new

    private let barCount = 36
    private let barWidth: CGFloat = 3.0

    @State private var tickPulse: Double = 0
    @State private var frozenT: Double = 0
    @State private var amplitude: Double = 0
    @State private var targetAmplitude: Double = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = currentT(now: timeline.date)
                let gap = (size.width - CGFloat(barCount) * barWidth) / CGFloat(barCount + 1)

                for i in 0..<barCount {
                    let x = gap + CGFloat(i) * (barWidth + gap)
                    let h = barHeight(index: i, total: barCount, t: t, size: size)
                    let y = size.height - h

                    let barFraction = Double(x) / Double(size.width)
                    let alpha: Double = barFraction <= progress ? 1.0 : 0.6

                    let rect = CGRect(x: x, y: y, width: barWidth, height: h)
                    let path = Path(roundedRect: rect, cornerRadius: 1.5)
                    context.fill(path, with: .color(.white.opacity(alpha)))
                }
            }
        }
        .frame(height: 86)
        .task {
            while !Task.isCancelled {
                let step = 0.04
                if abs(amplitude - targetAmplitude) > 0.001 {
                    amplitude += (targetAmplitude - amplitude) * step
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
        .onChange(of: secondsElapsed) { oldValue, newValue in
            triggerTickPulse()
        }
        .onChange(of: isAnimating) { oldRunning, newRunning in
            if newRunning {
                targetAmplitude = 1
            } else {
                frozenT = currentT(now: Date())
                targetAmplitude = 0
            }
        }
    }

    private func currentT(now: Date) -> Double {
        isAnimating ? now.timeIntervalSinceReferenceDate : frozenT
    }

//    private func barHeight(index: Int, total: Int, t: Double, size: CGSize) -> CGFloat {
//        let i = Double(index)
//        let n = Double(total)
//        let bars = settings.selected.waveformBars
//
//        // Sample the waveformBars array using the bar's normalised position,
//        // blending between the two nearest samples for a smooth envelope.
//        let barNorm   = i / (n - 1)                      // 0…1 across all bars
//        let scaled    = barNorm * Double(bars.count - 1)
//        let loIdx     = Int(scaled)
//        let hiIdx     = min(loIdx + 1, bars.count - 1)
//        let frac      = scaled - Double(loIdx)
//        let waveform  = Double(bars[loIdx]) * (1 - frac) + Double(bars[hiIdx]) * frac
//
//        // Original sine wave + symmetric arc envelope
//        let wave      = sin(i / n * .pi * 2.0 - t * 1.2) * 0.5 + 0.5
//        let envelope  = waveform                          // replaces the old 0.5+0.5*sin envelope
//
//        let peakPulse = tickPulse * exp(-tickPulse * 3.0) * 0.25
//        let base      = 0.18
//        let height    = base + wave * envelope * 0.62 * amplitude + peakPulse
//
//        return CGFloat(min(0.95, height)) * size.height
//    }
    
    private func barHeight(index: Int, total: Int, t: Double, size: CGSize) -> CGFloat {
        let i = Double(index)
        let n = Double(total)
        let bars = settings.selected.waveformBars

        // --- Waveform envelope: cosine interpolation for silky transitions ---
        let barNorm = i / (n - 1)
        let scaled  = barNorm * Double(bars.count - 1)
        let loIdx   = Int(scaled)
        let hiIdx   = min(loIdx + 1, bars.count - 1)
        let frac    = scaled - Double(loIdx)
        let cosF    = (1 - cos(frac * .pi)) / 2                          // cosine ease
        let waveform = Double(bars[loIdx]) * (1 - cosF) + Double(bars[hiIdx]) * cosF

        // --- Two sine layers at different speeds & spatial frequencies ---
        // Primary: slow, broad undulation — the "body" of the wave
        let primary   = sin(i / n * .pi * 2.2 - t * 1.0) * 0.5 + 0.5
        // Secondary: faster, tighter ripple — adds organic texture
        let secondary = sin(i / n * .pi * 4.5 - t * 1.8) * 0.5 + 0.5
        // Blend: primary carries 75%, secondary adds subtle shimmer
        let wave = primary * 0.75 + secondary * 0.25

        // --- Soft arc so edge bars never look too stubby ---
        let edgeSoften = 0.55 + 0.45 * sin(barNorm * .pi)

        // --- Tick pulse ---
        let peakPulse = tickPulse * exp(-tickPulse * 3.0) * 0.25

        let base   = 0.3
        let height = base + wave * waveform * edgeSoften * 0.65 * amplitude + peakPulse

        return CGFloat(min(0.95, height)) * size.height
    }

    private func triggerTickPulse() {
        tickPulse = 0
        withAnimation(.linear(duration: 0.8)) {
            tickPulse = 1
        }
    }
}
