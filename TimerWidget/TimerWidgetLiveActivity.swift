//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Created by Yuki Suzuki on 6/1/26.
//
import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents
import AVFoundation

nonisolated struct TimerWidgetAttributes: ActivityAttributes {
    nonisolated public struct ContentState: Codable, Hashable {
        var songTitle: String
        var isPlaying: Bool
        var endDate: Date
        var totalDuration: Double
        var secondRemaining: Double
        //var albumArtData: Data?
        var frozenRemaining: TimeInterval? = nil
    }
    // attributes is now empty (or add other fixed non-image fields)
    //var albumArtData: Data?

}

struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerWidgetAttributes.self) { context in
            
            // MARK: - Lock Screen / Banner UI
            MusicPlayerBannerView(context: context).activityBackgroundTint(Color.clear).activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Dynamic Island Expanded
                DynamicIslandExpandedRegion(.leading) {
                    
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 1) {
                        
                        Text(context.state.songTitle).font(.system(size: 13, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                        
                        Text(context.state.isPlaying ? "playing" : "paused").font(.system(size: 12)).foregroundColor(.white.opacity(0.75)).lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
//                        ProgressBarView(
//                            endDate: context.state.endDate,
//                            totalDuration: context.state.totalDuration,
//                            isPlaying: context.state.isPlaying
//                        )
                        ProgressBarView2(
                            endDate: context.state.endDate,
                            totalDuration: context.state.totalDuration,
                            isPlaying: context.state.isPlaying,
                            frozenRemaining: context.state.frozenRemaining
                        )
                        //PlaybackControlsView(isRunning: context.state.isPlaying, activityID: context.activityID)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                }
                
            } compactLeading: {
                    
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill").foregroundColor(.white).font(.system(size: 12))
                    
            } minimal: {
                Image(systemName: "music.note").foregroundColor(.white).font(.system(size: 10))
            }
            .widgetURL(URL(string: "myapp://nowplaying"))
            .keylineTint(Color.red)
        }
    }
}

// MARK: - Banner / Lock Screen View
struct MusicPlayerBannerView: View {
    let context: ActivityViewContext<TimerWidgetAttributes>

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.55, green: 0.1, blue: 0.1), Color(red: 0.3, green: 0.35, blue: 0.4)],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack(spacing: 12) {
                
                VStack(alignment: .leading, spacing: 10) {
                    // Song Info + Play/Pause button in same row
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.songTitle).font(.system(size: 15, weight: .bold)).foregroundColor(.white).lineLimit(1)
                            
                            Text(context.state.isPlaying ? "playing" : "paused").font(.system(size: 13)).foregroundColor(.white.opacity(0.8)).lineLimit(1)
                        }
                        Spacer()
                        //PlaybackControlsView(isRunning: context.state.isPlaying, activityID: context.activityID)
                    }
                    
                    // Progress Bar with timestamps
                    VStack(spacing: 3) {
                        // Call site in MusicPlayerBannerView
                        ProgressBarView2(
                            endDate: context.state.endDate,
                            totalDuration: context.state.totalDuration,
                            isPlaying: context.state.isPlaying,
                            frozenRemaining: context.state.frozenRemaining
                        )
                        HStack {
                            
                            if context.state.isPlaying {
                                // current elapsed
                                Text(context.state.endDate - context.state.totalDuration, style: .timer)
                                
                                Text(context.state.endDate, style: .timer).multilineTextAlignment(.trailing)
                            }else {
                                if let frozen = context.state.frozenRemaining {
                                    Text(formatTime(context.state.totalDuration - frozen))// elapsed = total - remaining
                                    Spacer()
                                    Text(formatTime(frozen))// static frozen display
                                }
                            }
                        }
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(height: 120)
        .cornerRadius(16)
    }
    
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Progress Bar
struct ProgressBarView: View {
    let endDate: Date
    let totalDuration: Double
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation) { context in
            let remaining = max(endDate.timeIntervalSinceNow, 0)
            let progress = totalDuration > 0
                ? 1.0 - (remaining / totalDuration)
                : 1.0
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.3)).frame(height: 3)
                    Capsule().fill(Color.white.opacity(0.9))
                        .frame(width: geo.size.width * progress, height: 3)
                }
            }
            .frame(height: 3)
        }

    }
}

struct ProgressBarView2: View {
    let endDate: Date
    let totalDuration: Double
    let isPlaying: Bool
    let frozenRemaining: Double?
    
    var body: some View {
        //Text("isPlaying \(isPlaying.description)")
        if isPlaying {
            let startDate = endDate.addingTimeInterval(-totalDuration)
            ProgressView(
                timerInterval: startDate...endDate,
                countsDown: false,
                label: { EmptyView() },
                currentValueLabel: { EmptyView() }
            )
            .progressViewStyle(.linear)
            .tint(Color.white.opacity(0.9))
            .clipShape(Capsule())
            .frame(height: 3)
            

        } else {
            // Frozen state — static bar
            if let frozenRemaining = frozenRemaining {
                let elapsed = totalDuration - frozenRemaining
                VStack(spacing: 3) {
                    ProgressView(value: elapsed, total: totalDuration)
                        .progressViewStyle(.linear)
                        .tint(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .frame(height: 3)
                }
            }
        }
    }
}

// MARK: - Playback Controls (play/pause only)
struct PlaybackControlsView: View {
    //@AppStorage("isPlaying", store: UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")) private var isRunning: Bool = false
    let isRunning: Bool
    let activityID: String
    var body: some View {
        
        if isRunning {
            Button(intent: PauseIntent()) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        } else {
            Button(intent: PlayIntent()) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct PauseIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Pause"
    static let openAppWhenRun: Bool = false  // stay in background

    func perform() async throws -> some IntentResult {
        let shared = UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")
        shared?.set(false, forKey: "isPlaying")
        
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.ysuzuki.ZenFlow.playbackChanged" as CFString),
            nil, nil, true
        )
        return .result()
    }
}

struct PlayIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Play"
    static let openAppWhenRun: Bool = false  // foreground to start audio

    func perform() async throws -> some IntentResult {
        let shared = UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")
        shared?.set(true, forKey: "isPlaying")
        
        // Re-activate audio session from within the intent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("PlayIntent: audio session activation failed: \(error)")
        }
        
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.ysuzuki.ZenFlow.playbackChanged" as CFString),
            nil, nil, true
        )
        return .result()
    }
}

// MARK: - Attribute & State Extensions
extension TimerWidgetAttributes {
    fileprivate static var preview: TimerWidgetAttributes {
        //let albumArt = UIImage(named: "blond_cover")
        return TimerWidgetAttributes()
    }
}

extension TimerWidgetAttributes.ContentState {
    fileprivate static var playing: TimerWidgetAttributes.ContentState {
        
        TimerWidgetAttributes.ContentState(
            songTitle: "CrystalBowl",
            isPlaying: true,
            endDate: Date().addingTimeInterval(Double(60)),
            totalDuration: 180,
            secondRemaining: 60.0
        )
    }
    
    fileprivate static var paused: TimerWidgetAttributes.ContentState {
        
        TimerWidgetAttributes.ContentState(
            songTitle: "WhaleDiving",
            isPlaying: false,
            endDate: Date().addingTimeInterval(Double(214)),
            totalDuration: 307,
            secondRemaining: 214.0,
            frozenRemaining: Date().addingTimeInterval(Double(214)).timeIntervalSinceNow
        )
    }
}

// MARK: - Previews
#Preview("Notification", as: .content, using: TimerWidgetAttributes.preview) {
    TimerWidgetLiveActivity()
} contentStates: {
    TimerWidgetAttributes.ContentState.playing
    TimerWidgetAttributes.ContentState.paused
}
