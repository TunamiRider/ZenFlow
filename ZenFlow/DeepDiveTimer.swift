//
//  ContentView.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI

import SwiftUI
import AVPlayerPlus
import AVFoundation
struct DeepDiveTimer: View {

    // MARK: - State
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var isSnoozed: Bool = false
    @State private var timer: Timer? = nil
    @State private var isFinished: Bool = false
    @State private var showDescription: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var minutes: Int = 5
    private let dingPlayer = AVPlayer.dingPlayer()
    private let dingIntervalPlayer = AVPlayer.dingIntervalPlayer()
    
    private let deepOceanPlayer = AVPlayer.deepOceanPlayer()
    private let rainDrizzleThunderPlayer = AVPlayer.rainDrizzleThunderPlayer()
    private let seasideRocksShorePlayer = AVPlayer.seasideRocksShorePlayer()
    private let seaLagoonWavesPlayer = AVPlayer.seaLagoonWavesPlayer()
    private let underWaterRainPlayer = AVPlayer.underWaterRainPlayer()
    private let underwaterWhaleDivingPlayer = AVPlayer.underwaterWhaleDivingPlayer()
    private let crystalBowlPlayer = AVPlayer.crystalBowlPlayer()
    private let modernSutraPlayer = AVPlayer.modernSutraPlayer()
    
    @State var currentPlayer: AVPlayer?
    @State private var settings = PlayerSettings()
    @State private var showSheet = false
    @State private var selectedDetent: PresentationDetent = .large
    @State private var yogaIconColorMultiplier = Color(red: 0.75, green: 0.75, blue: 0.75)
    
    private func switchPlayer(){
        switch settings.selected {
        case .deepOcean:
            currentPlayer = deepOceanPlayer
        case .rainDrizzleThunder:
            currentPlayer = rainDrizzleThunderPlayer
        case .seasideRocksShore:
            currentPlayer = seasideRocksShorePlayer
        case .seaLagoonWaves:
            currentPlayer = seaLagoonWavesPlayer
        case .underWaterRain:
            currentPlayer = underWaterRainPlayer
        case .underwaterWhaleDiving:
            currentPlayer = underwaterWhaleDivingPlayer
        case .crystalBowl:
            currentPlayer = crystalBowlPlayer
        case .modernSutra:
            currentPlayer = modernSutraPlayer
        }
    }
    private func switchColorMultiplier(){
        switch settings.selected {
        case .deepOcean:
            yogaIconColorMultiplier = Color(red: 0.50, green: 0.57, blue: 0.62)//Color(red: 0.7, green: 0.7, blue: 0.85)
        case .rainDrizzleThunder:
            yogaIconColorMultiplier = Color(red: 0.51, green: 0.5, blue: 0.49)
        case .seasideRocksShore:
            yogaIconColorMultiplier = Color(red: 0.77, green: 0.69, blue: 0.6)
        case .seaLagoonWaves:
            yogaIconColorMultiplier = Color(red: 0.4, green: 0.5, blue: 0.55)
        case .underWaterRain:
            yogaIconColorMultiplier = Color(red: 0.77, green: 0.92, blue: 0.92).opacity(0.5)
        case .underwaterWhaleDiving:
            yogaIconColorMultiplier = Color(red: 0.46, green: 0.51, blue: 0.6).opacity(0.8)//Color(red: 0.86, green: 0.86, blue: 0.95)
        case .crystalBowl:
            yogaIconColorMultiplier = Color(red: 0.75, green: 0.75, blue: 0.75)
        case .modernSutra:
            yogaIconColorMultiplier = Color(red: 0.74, green: 0.64, blue: 0.64)
        }
    }
    
    // MARK: - Computed
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    private var displayMinutes: Int { secondsRemaining / 60 }
    private var displaySeconds: Int { secondsRemaining % 60 }
    

    // MARK: - Body
    var body: some View {
        ZStack {
            
            OceanBackground(imagePath: settings.backgroundImagePath)
                .ignoresSafeArea()
                .id(settings.backgroundImagePath)
                .transition(.opacity)
            
            // ── Close button ───────────────────────────────
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                            .foregroundColor((isRunning || isSnoozed) ? .white.opacity(0.2) : .white.opacity(0.9))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .clipShape(Capsule())
                    }
                    .disabled(isRunning || isSnoozed)
                    
                }
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()

                // ── Circular dial ──────────────────────────────────────────
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 240, height: 240)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white.opacity(0.70), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Dot indicator at tip of arc
                    dotIndicator

                    // Time display
                    VStack(spacing: 4) {
                        Image("yogaIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .background(Color.clear)
                            //.colorMultiply(.gray)
                            .colorMultiply(yogaIconColorMultiplier)
                            //.brightness(-0.2)
                            .id(settings.backgroundImagePath)
                            .transition(.opacity)
                            
                    }
                }
                .frame(width: 240, height: 240)

                Spacer()
                
                // ── Wave tick visualization ────────────────────────────────
                WaveTick(
                    progress: progress,
                    secondsElapsed: totalSeconds - secondsRemaining,
                    isAnimating: isRunning,
                    settings: settings
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
                
                //Spacer()

                // ── Label ──────────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text(isFinished ? "Time's up" : isRunning ? settings.selected.displayName : "Lull")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 6) {
                    Text("Duration")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                    DurationPicker(minutes: $minutes, isRunning: (isRunning || isSnoozed))
                }
                Spacer(minLength: 10)
                
                // ── Buttons ────────────────────────────────────────────────
                VStack(spacing: 16) {

                    // Get up / Start
                    Button {
                        if isFinished || !isRunning {
                            startTimer()
                        } else {
                            getUp()
                        }
                    } label: {
                        Text(isFinished ? "New Session" : isRunning ? "Pause" : isSnoozed ? "Start again" : "Start focus")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.white.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 40)
                }

                Spacer(minLength: 50)
            }
        }
        .animation(.easeInOut(duration: 3), value: settings.backgroundImagePath)
        .onAppear {
            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds
            //startTimer()
            
            switchPlayer()
            switchColorMultiplier()
            
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: isFinished){ oldValue, newValue in
            if newValue {
                isSnoozed = false
            }
        }
        .onChange(of: minutes){oldValue, newValue in
            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds
        }
        .sheet(isPresented: $showSheet) {
            SoundPickerSheet(
                selectedSound: $settings.selected,
                dingEnabled: $settings.dingEnabled,
                dingInterval: $settings.dingInterval
            )
            .presentationDetents([.large, .medium], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
            .onAppear(){
                selectedDetent = .large
            }
        }
        .onChange(of: showSheet) { _, newValue in
            if !newValue { // sheet is closing / dismissed
                withAnimation(.easeInOut(duration: 3)) {
                    switchPlayer()
                    switchColorMultiplier()
                    resetTimer()
                }

            }
        }
    }

    // MARK: - Dot indicator
    private var dotIndicator: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = geo.size.width / 2
            let angle = (progress * 360 - 90) * .pi / 180
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
        }
        .frame(width: 240, height: 240)
    }
    
    private func resetTimer() {
        isSnoozed = false
        isFinished = false
        // Reset if needed
        if secondsRemaining == 0 {

            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds
            currentPlayer?.volume = 1.0
            currentPlayer?.reset()
        }
    }

    // MARK: - Timer logic
    private func startTimer() {
//        isSnoozed = false
//        isFinished = false

        resetTimer()

        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            Task { @MainActor in
                let startOrEnd = secondsRemaining == totalSeconds || secondsRemaining == 0
                
                if startOrEnd /*secondsRemaining % 60 == 0*/ {
                    dingPlayer.seek(to: .zero)
                    dingPlayer.play()
                }
                // Interval sound
                let isIntervalSound = settings.dingEnabled && secondsRemaining % settings.totalSeconds == 0
                if !startOrEnd && isIntervalSound {
                    dingIntervalPlayer.seek(to: .zero)
                    dingIntervalPlayer.play()
                }
                // Interval sound
                guard isRunning else { return }

                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                    if secondsRemaining<=10 { currentPlayer?.volume = Float(secondsRemaining) / 10 }
                    
                } else {
                    isFinished = true
                    stopTimer()
                    currentPlayer?.volume = 1.0
                    currentPlayer?.reset()
                }
            }

        }

        //deepOceanPlayer.startLooping()
        currentPlayer?.startLooping()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        isSnoozed = true
        //deepOceanPlayer.stopLooping()
        currentPlayer?.stopLooping()
    }

    private func snooze() {
        stopTimer()
        isSnoozed = true
        // Snooze for 5 minutes
        let mins = 1
        totalSeconds = mins * 60
        secondsRemaining = totalSeconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            startTimer()
        }
    }

    private func getUp() {
        stopTimer()
        // Notify completion — in a real app you'd call bubble.markCompleted() or dismiss
    }
}



// MARK: - Preview
#Preview {
    DeepDiveTimer()
}
