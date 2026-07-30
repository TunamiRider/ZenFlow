//
//  ContentView.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI
import SwiftData
import AVPlayerPlus
import AVFoundation
import ActivityKit

struct DeepDiveTimer: View {

    // MARK: - State
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @AppStorage("isPlaying", store: UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")) private var isRunning: Bool = false
    @State private var isSnoozed: Bool = false
    @State private var timer: Timer? = nil
    @State private var isFinished: Bool = false
    @State private var showDescription: Bool = false
    @Environment(\.dismiss) private var dismiss

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
    
    @State private var currentPlayer: AVPlayer?
    @State private var settings = PlayerSettings.load()
    @State private var showSheet = false
    @State private var selectedDetent: PresentationDetent = .large
    @State private var yogaIconColorMultiplier = Color(red: 0.75, green: 0.75, blue: 0.75)
    
    //Detect speaker change
    private let notificationCenter = NotificationCenter.default
    @State private var routeChangeObserver: NSObjectProtocol?
    @State private var interruptionObserver: NSObjectProtocol?
    
    //WidgetActivity
    @State private var timerWidgetActivity:TimerWidgetActivity = TimerWidgetActivity()
    @State private var isHandlingWidgetIntent = false
    
    @State private var isOnlyResetTimer: Bool = false
    
    
    @State private var today = Date()
    
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private func isToday(day: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return day == formatter.string(from: today)
    }
    
    private func switchPlayer(){
        let previousPlayer = currentPlayer
        let newPlayer: AVPlayer
        
        switch settings.selected {
        case .deepOcean:
            newPlayer = deepOceanPlayer
        case .rainDrizzleThunder:
            newPlayer = rainDrizzleThunderPlayer
        case .seasideRocksShore:
            newPlayer = seasideRocksShorePlayer
        case .seaLagoonWaves:
            newPlayer = seaLagoonWavesPlayer
        case .underWaterRain:
            newPlayer = underWaterRainPlayer
        case .underwaterWhaleDiving:
            newPlayer = underwaterWhaleDivingPlayer
        case .crystalBowl:
            newPlayer = crystalBowlPlayer
        case .modernSutra:
            newPlayer = modernSutraPlayer
        }
        
        if let previousPlayer, previousPlayer !== newPlayer {
            previousPlayer.pauseWithoutStopping()
        }
        
        currentPlayer = newPlayer
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
            yogaIconColorMultiplier = Color(red: 0.35, green: 0.6, blue: 0.58)
        case .underWaterRain:
            yogaIconColorMultiplier = Color(red: 0.77, green: 0.92, blue: 0.92)//.opacity(0.9)
        case .underwaterWhaleDiving:
            yogaIconColorMultiplier = Color(red: 0.46, green: 0.51, blue: 0.6)//.opacity(0.95)//Color(red: 0.86, green: 0.86, blue: 0.95)
        case .crystalBowl:
            yogaIconColorMultiplier = Color(red: 0.75, green: 0.75, blue: 0.75)
        case .modernSutra:
            yogaIconColorMultiplier = Color(red: 0.74, green: 0.64, blue: 0.64)
        }
    }
    
    @discardableResult
    private func resetAllSeekToZero() async -> Bool {
        
        deepOceanPlayer.volume = 0.0
        await deepOceanPlayer.seek(to: .zero)
        deepOceanPlayer.pause()
        deepOceanPlayer.volume = 1.0
        
        rainDrizzleThunderPlayer.volume = 0.0
        await rainDrizzleThunderPlayer.seek(to: .zero)
        rainDrizzleThunderPlayer.pause()
        rainDrizzleThunderPlayer.volume = 1.0
        
        seasideRocksShorePlayer.volume = 0.0
        await seasideRocksShorePlayer.seek(to: .zero)
        seasideRocksShorePlayer.pause()
        seasideRocksShorePlayer.volume = 1.0
        
        seaLagoonWavesPlayer.volume = 0.0
        await seaLagoonWavesPlayer.seek(to: .zero)
        seaLagoonWavesPlayer.pause()
        seaLagoonWavesPlayer.volume = 1.0
        
        underWaterRainPlayer.volume = 0.0
        await underWaterRainPlayer.seek(to: .zero)
        underWaterRainPlayer.pause()
        underWaterRainPlayer.volume = 1.0
        
        underwaterWhaleDivingPlayer.volume = 0.0
        await underwaterWhaleDivingPlayer.seek(to: .zero)
        underwaterWhaleDivingPlayer.pause()
        underwaterWhaleDivingPlayer.volume = 1.0
        
        underwaterWhaleDivingPlayer.volume = 0.0
        await crystalBowlPlayer.seek(to: .zero)
        crystalBowlPlayer.pause()
        crystalBowlPlayer.volume = 1.0
        
        modernSutraPlayer.volume = 0.0
        await modernSutraPlayer.seek(to: .zero)
        modernSutraPlayer.pause()
        modernSutraPlayer.volume = 1.0
        
        // Make sure nothing but currentPlayer can be audible after a settings visit
//        for player in [deepOceanPlayer, rainDrizzleThunderPlayer, seasideRocksShorePlayer,
//                       seaLagoonWavesPlayer, underWaterRainPlayer, underwaterWhaleDivingPlayer,
//                       crystalBowlPlayer, modernSutraPlayer] where player !== currentPlayer {
//            player.pauseWithoutStopping()
//        }
        
        return true
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
                ZStack {
                    VStack(alignment: .center, spacing: 4) {
                        Spacer().frame(height: 10)
                        Text("ZenFlow")
                            //.font(.system(size: 34, weight: .bold))
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(1), radius: 1, x: 0, y: 1)
                        
                        HStack(spacing: 12) {
                            ForEach(days, id: \.self) { day in
                                Text(day.prefix(1))
                                    .font(.system(size: 13, weight: isToday(day: day) ? .bold : .medium))
                                    .foregroundColor(isToday(day: day) ? .white : .white.opacity(0.5))
                            }
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Spacer()
                        Button {
                            showSheet = true
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .foregroundColor((isRunning && !isSnoozed) ? .white.opacity(0.2) : .white.opacity(0.9))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .clipShape(Capsule())
                        }
                        .disabled(isRunning && !isSnoozed)
                        .shadow(color: Color.black.opacity(1), radius: 1, x: 0, y: 1)
                    }
                }
                Spacer()
            }//.border(Color.yellow)

            VStack(spacing: 0) {
                Spacer().frame(height: 100)

                // ── Circular dial ──────────────────────────────────────────
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white.opacity(0.70), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Dot indicator at tip of arc
                    dotIndicator

                    // MARK: Yoga Icon
//                    VStack(spacing: 4) {
//                        Image("yogaIcon")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 180, height: 180)
//                            .background(Color.clear)
//                            .colorMultiply(yogaIconColorMultiplier)
//                            .id(settings.backgroundImagePath)
//                            .transition(.opacity)
//                            
//                    }
                    VStack(spacing: 4) {
                        Image("yogaIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            //.background(Color.clear)
                            .colorMultiply(yogaIconColorMultiplier)
                            .brightness(0.15)
                            //.opacity(0.9)
                            .shadow(color: .white.opacity(0.2), radius: 2)
                            .shadow(color: .white.opacity(0.1), radius: 1)
                            //.shadow(color: .black.opacity(0.4), radius: 4)
                            .padding(.top, 25)
                            .id(settings.backgroundImagePath)
                            .transition(.opacity)
                    }
                }
                .frame(width: 240, height: 240)

                //Spacer().frame(height: 10)
                
                // ── Wave tick visualization ────────────────────────────────
                WaveTick(
                    progress: progress,
                    secondsElapsed: totalSeconds - secondsRemaining,
                    isAnimating: isRunning,
                    settings: settings
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
                .shadow(color: Color.black.opacity(1), radius: 2, x: 0, y: 1)

                // ── Label ──────────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text(isFinished ? "Time's up" : settings.selected.displayName).font(.system(size: 18, weight: .semibold, design: .default)).foregroundColor(.white)
                        .shadow(color: Color.black.opacity(1), radius: 1, x: 0, y: 1)
                }

                Spacer().frame(height: 20)

                VStack(spacing: 6) {
                    Text("Duration").font(.system(size: 18, weight: .semibold, design: .default)).foregroundColor(.white)
                        .shadow(color: Color.black.opacity(1), radius: 1, x: 0, y: 1)
                    DurationPicker(minutes: $settings.duration, isRunning: (isRunning && !isSnoozed))
                }
                //Spacer(minLength: 10)
                Spacer()
                
                // ── Buttons ────────────────────────────────────────────────
                VStack(spacing: 16) {

                    Button {
//                        if isFinished {
//                            resetAllSeekToZero()
//                        }
                        
                        if isFinished || !isRunning {
                            startTimer()
                        } else {
                            stopTimer()
                        }
                    } label: {
                        Text(isFinished ? "New Session" : isRunning ? "Pause" : (isRunning && !isSnoozed) ? "Start again" : "Start focus")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38, maxHeight: 48)
                            .background(Color.white.opacity(0.28))
                            .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                        
                    }
                    .disabled(isOnlyResetTimer && progress>0.0)
                    .padding(.horizontal, 40)
                    
                    Button {
                        stopTimer()
                        isOnlyResetTimer = true
                        stopObservingRouteChanges()
                        stopObservingInterruptions()
                        
                        
                        let targetSeconds = settings.duration * 60
                        totalSeconds = targetSeconds
                        let startSeconds = secondsRemaining
                        
                        let steps = 20
                        let durationNanoseconds = UInt64(1.0 * 1_000_000_000 / Double(steps))
                            
                            Task { @MainActor in
                                for step in 1...steps {
                                    let progress = Double(step) / Double(steps)
                                    let newValue = Double(startSeconds) + (Double(targetSeconds - startSeconds) * progress)
                                    
                                    withAnimation(.linear(duration: 0.8)) {
                                        secondsRemaining = Int(newValue)
                                    }
                                    
                                    try? await Task.sleep(nanoseconds: durationNanoseconds)
                                }
                                
                                secondsRemaining = targetSeconds
                            }
                        
                    } label: {
                        Text("Reset Timer")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38, maxHeight: 48)
                            .background(Color.white.opacity(0.28))
                            .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 40)
                    .disabled(!isSnoozed || progress==0.0)
                    .opacity((!isSnoozed || progress==0.0) ? 0 : 1)
                    .scaleEffect(isSnoozed ? 1.0 : 0.8)
                    .animation(.spring(response: 0.85, dampingFraction: 0.8), value: isSnoozed)

                }

                Spacer(minLength: 50)
            }
        }
        .animation(.easeInOut(duration: 3), value: settings.backgroundImagePath)
        .onAppear {
            totalSeconds = settings.duration * 60
            secondsRemaining = totalSeconds
            
            switchPlayer()
            switchColorMultiplier()
            
            starOobserveRouteChanges()
            startObservingInterruptions()
            
            CFNotificationCenterAddObserver(
                CFNotificationCenterGetDarwinNotifyCenter(),
                nil,
                { _, _, _, _, _ in
                    
                    DispatchQueue.main.async{
                        // now isRunning's onChange fires on the right thread
                        // and startTimer() / AVAudioSession run on main
                        let shared = UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")
                        let isNowPlaying = shared?.bool(forKey: "isPlaying") ?? false
                        //print("🔔 Darwin callback fired, isPlaying: \(shared?.bool(forKey: "isPlaying") ?? false)")
                        
                        if isNowPlaying {
                            // Can't call self here (C callbacl) - post a local NSNotification instead
                            NotificationCenter.default.post(name: .init("ZenFlowResumeFromWidget")
                                                            ,object: nil
                                                            ,userInfo: ["fromLockScreen": true]
                            )
                        }
                    }
                    // isRunning already changed via shared UserDefaults — onChange picks it up
                },
                "com.ysuzuki.ZenFlow.playbackChanged" as CFString,
                nil,
                .deliverImmediately
            )
        }
        .onDisappear {
            stopTimer()
            stopObservingRouteChanges()
            stopObservingInterruptions()
            
        }
        .onChange(of: isFinished){ oldValue, newValue in
            if newValue {
                isSnoozed = false
            }
        }
        .onChange(of: settings.duration){oldValue, newValue in
            UserDefaults.standard.set(settings.duration, forKey: "duration")
            totalSeconds = settings.duration * 60
            secondsRemaining = totalSeconds
        }
        .sheet(isPresented: $showSheet) {
            SoundPickerSheet(
                selectedSound: $settings.selected,
                dingEnabled: $settings.dingEnabled,
                dingInterval: $settings.dingInterval,
                isWidgetOn: $settings.isWidgetOn
            )
            .presentationDetents([.large, .medium], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
            .onAppear(){
                selectedDetent = .large
            }
        }
        .onChange(of: showSheet) { _, newValue in
            if !newValue { // sheet is closing / dismissed
//                stopObservingRouteChanges()
//                stopObservingInterruptions()
                
                withAnimation(.easeInOut(duration: 3)) {
                    //loadPlayerSettings()
                    switchPlayer()
                    switchColorMultiplier()
                    //resetTimer()
                    //isSnoozed = true
                    if !settings.isWidgetOn {
                        Task{
                            await timerWidgetActivity.endLiveActivity()
                        }
                    }
                    
                }
//                starOobserveRouteChanges()
//                startObservingInterruptions()
                // Make sure nothing but currentPlayer can be audible after a settings visit
//                for player in [deepOceanPlayer, rainDrizzleThunderPlayer, seasideRocksShorePlayer,
//                               seaLagoonWavesPlayer, underWaterRainPlayer, underwaterWhaleDivingPlayer,
//                               crystalBowlPlayer, modernSutraPlayer] where player !== currentPlayer {
//                    player.pauseWithoutStopping()
//                }
            }
        }
        .onChange(of: isRunning) { oldValue, newValue in
            guard !isHandlingWidgetIntent else { return }
            isHandlingWidgetIntent = true
            defer { isHandlingWidgetIntent = false }
            
            if newValue && timer == nil {
                startTimer()
                
            } else if !newValue && timer != nil {
                stopTimer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("ZenFlowResumeFromWidget"))){ notification in
            
            if timer == nil {
                startTimer()
            }
            let fromLockScreen = notification.userInfo?["fromLockScreen"] as? Bool ?? false
            if fromLockScreen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIControl().sendAction(
                        #selector(URLSessionTask.suspend),
                        to: UIApplication.shared,
                        for: nil
                    )
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
        //.animation(.easeInOut(duration: 0.5), value: progress)
    }
    
//    private func resetTimer() {
//        isSnoozed = false
//        isFinished = false
//        // Reset if needed
//        
//        if isOnlyResetTimer {
//            isOnlyResetTimer = false
//            return
//        }
//        
//        if secondsRemaining == 0 {
//            stopObservingRouteChanges()
//            stopObservingInterruptions()
//
////            totalSeconds = settings.duration * 60
////            secondsRemaining = totalSeconds
//            let targetSeconds = settings.duration * 60
//            totalSeconds = targetSeconds
//            let startSeconds = secondsRemaining
//            
//            let steps = 20
//            let durationNanoseconds = UInt64(1.0 * 1_000_000_000 / Double(steps))
//                
//                Task { @MainActor in
//                    for step in 1...steps {
//                        let progress = Double(step) / Double(steps)
//                        let newValue = Double(startSeconds) + (Double(targetSeconds - startSeconds) * progress)
//                        
//                        withAnimation(.linear(duration: 0.8)) {
//                            secondsRemaining = Int(newValue)
//                        }
//                        
//                        try? await Task.sleep(nanoseconds: durationNanoseconds)
//                    }
//                    
//                    secondsRemaining = targetSeconds
//                    
//                    try? await Task.sleep(nanoseconds: 1_000_000_000)
//                }
//            
//            currentPlayer?.reset()
//            
//        }
//    }
    
    @discardableResult
    private func resetTimer() async -> Bool {
        isSnoozed = false
        isFinished = false
        if isOnlyResetTimer {
            isOnlyResetTimer = false
            return false
        }
        guard secondsRemaining == 0 else { return false }

        stopObservingRouteChanges()
        stopObservingInterruptions()

        let targetSeconds = settings.duration * 60
        totalSeconds = targetSeconds
        let startSeconds = secondsRemaining
        let steps = 20
        let durationNanoseconds = UInt64(1.0 * 1_000_000_000 / Double(steps))

        for step in 1...steps {
            let progress = Double(step) / Double(steps)
            let newValue = Double(startSeconds) + (Double(targetSeconds - startSeconds) * progress)
            withAnimation(.linear(duration: 0.8)) {
                secondsRemaining = Int(newValue)
            }
            try? await Task.sleep(nanoseconds: durationNanoseconds)
        }
        secondsRemaining = targetSeconds
        currentPlayer?.reset()
        return true
    }

    @discardableResult
    private  func activateAudioSession(maxAttempts: Int = 3, delaySeconds: Double = 0.15) async -> Bool {
        for attempt in 1...maxAttempts {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                return true
            } catch {
                if attempt < maxAttempts {
                    try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                }
            }
        }
        return false
    }
    // MARK: - Timer logic
//    private func startTimer() {
//        guard timer == nil else { return }
//        let isResume = isSnoozed
//        print("startTimer")
//        resetTimer()
//        
//        
//        UIApplication.shared.isIdleTimerDisabled = true  // ← keep screen on
//        
//        if settings.isWidgetOn {
//            // ONE update when starting — pass the endDate
//            let endDate = Date().addingTimeInterval(Double(secondsRemaining))
//            Task {
//                await timerWidgetActivity.startOrUpdate(
//                    displayName: settings.selected.displayName,
//                    endDate: endDate,
//                    totalSeconds: Double(totalSeconds),
//                    isRunning: true
//                )
//            }
//        }
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            
//            Task { @MainActor in
//                let startOrEnd = secondsRemaining == totalSeconds || secondsRemaining == 0
//                
//
//                if startOrEnd /*secondsRemaining % 60 == 0*/ {
//                    dingPlayer.seek(to: .zero)
//                    dingPlayer.play()
//                    print("Ding start \(settings.selected.displayName)")
//                    print("secondsRemaining : \(secondsRemaining)")
//                    print("totalSeconds : \(totalSeconds)")
//                    print("")
//                    
//                }
//                // Interval sound
//                let isIntervalSound = settings.dingEnabled && (totalSeconds - secondsRemaining) % (settings.dingInterval * 60) == 0
//                if !startOrEnd && isIntervalSound {
//                    dingIntervalPlayer.seek(to: .zero)
//                    dingIntervalPlayer.play()
//                }
//                // Interval sound
//                guard isRunning else { return }
//
//                if secondsRemaining > 0 {
//                    secondsRemaining -= 1
//                    if secondsRemaining<=10 { currentPlayer?.volume = Float(secondsRemaining) / 10 }
//                } else {
//                    isFinished = true
//                    stopTimer()
//                    currentPlayer?.reset()
//                    if settings.isWidgetOn {
//                        Task{
//                            await timerWidgetActivity.endLiveActivity()
//                        }
//                    }
//                }
//            }
//        }
//        
//        isRunning = true
//        Task { @MainActor in
//            // Single, retry-capable activation — never call setActive again in resumeFromSilent
//            let activated = await activateAudioSession()
//            guard activated else { return }
//            if isResume {
//                currentPlayer?.resumeFromSilent()  // picks up where it left off
//            } else {
//                currentPlayer?.startLooping()   // seeks to zero, fresh start
//            }
//        }
//        starOobserveRouteChanges()
//        startObservingInterruptions()
//    }
    private func startTimer() {
        guard timer == nil else { return }
        let isResume = isSnoozed
        
        Task { @MainActor in
            if isFinished {
                await resetAllSeekToZero()
            }
            await resetTimer()
            
            UIApplication.shared.isIdleTimerDisabled = true  // ← keep screen on
            
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                
                Task { @MainActor in
                    let startOrEnd = secondsRemaining == totalSeconds || secondsRemaining == 0
                    
                    
                    if startOrEnd /*secondsRemaining % 60 == 0*/ {
                        dingPlayer.seek(to: .zero)
                        dingPlayer.play()
                    }
                    // Interval sound
                    let isIntervalSound = settings.dingEnabled && (totalSeconds - secondsRemaining) % (settings.dingInterval * 60) == 0
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
                        currentPlayer?.reset()
                        if settings.isWidgetOn {
                            Task{
                                await timerWidgetActivity.endLiveActivity()
                            }
                        }
                    }
                }
            }
            
            isRunning = true
            Task { @MainActor in
                // Single, retry-capable activation — never call setActive again in resumeFromSilent
                let activated = await activateAudioSession()
                guard activated else { return }
                //currentPlayer?.volume = 1.0
                if isResume {
                    currentPlayer?.resumeFromSilent()  // picks up where it left off
                } else {
                    currentPlayer?.startLooping()   // seeks to zero, fresh start
                }
            }
            
            if settings.isWidgetOn {
                // ONE update when starting — pass the endDate
                let endDate = Date().addingTimeInterval(Double(secondsRemaining))
                Task {
                    await timerWidgetActivity.startOrUpdate(
                        displayName: settings.selected.displayName,
                        endDate: endDate,
                        totalSeconds: Double(totalSeconds),
                        isRunning: true
                    )
                }
            }
            
            starOobserveRouteChanges()
            startObservingInterruptions()
        }
        
        
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isSnoozed = true
        UIApplication.shared.isIdleTimerDisabled = false  // ← allow screen to sleep
        
        if isFinished {
            currentPlayer?.stopLooping()
        } else {
            currentPlayer?.pauseWithoutStopping()
        }
        
        if settings.isWidgetOn {
            Task(priority: .userInitiated) {
                await timerWidgetActivity.pause()
            }
        }

    }
    
    private func stopTimerOnly() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isSnoozed = true
        UIApplication.shared.isIdleTimerDisabled = false  // ← allow screen to sleep

        if isFinished{
            currentPlayer?.stopLooping()
            
        } else {
            currentPlayer?.pauseWithoutStopping()
        }
    }
    
    private func starOobserveRouteChanges() {
        guard routeChangeObserver == nil else { return }
        
        routeChangeObserver = notificationCenter.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue),
                  reason == .oldDeviceUnavailable else {
                return
            }
            
            // Earphones unplugged → stop timer and player
            Task { @MainActor in
                //print("Earphones unplugged → stop timer and player")
                self.stopTimerOnly()  // stop player/timer
                
                if settings.isWidgetOn {
                    await timerWidgetActivity.endLiveActivity()  // update widget
                    
                    // ONE update when starting — pass the endDate
                    let endDate = Date().addingTimeInterval(Double(secondsRemaining))
                    await timerWidgetActivity.startOrUpdate(
                        displayName: settings.selected.displayName,
                        endDate: endDate,
                        totalSeconds: Double(totalSeconds),
                        isRunning: false
                    )
                }
                
            }

        }
    }

    private func stopObservingRouteChanges() {
        if let observer = routeChangeObserver {
            notificationCenter.removeObserver(observer)
            routeChangeObserver = nil
        }
    }
    
    
    func startObservingInterruptions() {
        guard interruptionObserver == nil else { return }
        
        interruptionObserver = notificationCenter.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { notification in

            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }

            switch type {
            case .began:
                // Other app started playing audio → stop your player
                Task { @MainActor in
                    self.stopTimer()
                    
                    if settings.isWidgetOn {
                        await timerWidgetActivity.endLiveActivity()  // update widget
                        
                        // ONE update when starting — pass the endDate
                        let endDate = Date().addingTimeInterval(Double(secondsRemaining))
                        await timerWidgetActivity.startOrUpdate(
                            displayName: settings.selected.displayName,
                            endDate: endDate,
                            totalSeconds: Double(totalSeconds),
                            isRunning: false
                        )
                    }

                }
            case .ended:
                // Interruption ended → you can optionally resume if you want
                // For now, we keep it stopped (user must tap play again)

                // ✅ Reactivate session immediately when interruption ends
                // even if user doesn't tap play yet — keeps session "warm"
//                let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
//                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue ?? 0)
//                    
//                    // Only auto-resume if system says we should (e.g. phone call ended)
//                    // For earphone unplug we deliberately do NOT auto-resume
//                    if options.contains(.shouldResume) && self.isSnoozed {
//                        // optional: auto-resume here if you want
//                    }
//                }
                
                break
            @unknown default:
                break
            }
        }
    }

    func stopObservingInterruptions() {
        if let observer = interruptionObserver {
            notificationCenter.removeObserver(observer)
            interruptionObserver = nil
        }
    }

}



// MARK: - Preview
#Preview {
    DeepDiveTimer()
}
