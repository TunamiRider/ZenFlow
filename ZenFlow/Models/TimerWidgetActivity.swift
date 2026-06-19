//
//  TimerWidgetActivity.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 6/2/26.
//

import Foundation
import Combine
import ActivityKit

actor TimerWidgetActivity {
    var displayName: String = "😀"
    var endDate: Date = Date().addingTimeInterval(Double(60))
    var totalSeconds: Double = 180
    var isRunning: Bool = false
    //var secondRemaining: Double = 60.0

    private var activityID: String?
    var isActive: Bool { activityID != nil }
    
    // Helper to compute remaining seconds from endDate
    var secondsRemaining: Double {
        let remaining = endDate.timeIntervalSinceNow
        return remaining > 0 ? remaining : 0
    }

    // MARK: - Start
    func startLiveActivity(displayName: String, endDate: Date, totalSeconds: Double, isRunning: Bool) {
        self.displayName = displayName
        self.endDate = endDate
        self.totalSeconds = totalSeconds
        self.isRunning = isRunning
        
        let attributes = TimerWidgetAttributes()
        let initialState = TimerWidgetAttributes.ContentState(
            songTitle: displayName,
            isPlaying: isRunning,
            endDate: endDate,
            totalDuration: totalSeconds,
            secondRemaining: self.secondsRemaining
        )
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            let activity = try Activity<TimerWidgetAttributes>.request(
                attributes: attributes,
                content: content
            )
            // ✅ Only store the ID, never the Activity object itself
            self.activityID = activity.id
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    // MARK: - Update
    func updateLiveActivity(displayName: String? = nil, endDate: Date? = nil, isRunning: Bool? = nil) {
        if let displayName      { self.displayName = displayName }
        if let endDate { self.endDate = endDate }
        if let isRunning        { self.isRunning = isRunning }
        
        
        guard let activityID else { return }
        
        let frozenRemaining: TimeInterval? = !self.isRunning ? ceil(self.endDate.timeIntervalSinceNow) : nil
        
        let newState = TimerWidgetAttributes.ContentState(
            songTitle: self.displayName,
            isPlaying: self.isRunning,
            endDate: self.endDate,
            totalDuration: self.totalSeconds,
            secondRemaining: self.secondsRemaining,
            frozenRemaining: frozenRemaining
        )
        let activityContent = ActivityContent(state: newState, staleDate: nil)
        
//        // ✅ Only ID (String) crosses the boundary — fully Sendable
//        Task.detached {
//            guard let activity = Activity<TimerWidgetAttributes>.activities
//                .first(where: { $0.id == activityID }) else { return }
//            await activity.update(activityContent)
//            print("Live Activity updated to paused \(await self.isRunning)")
//        }
        Task.detached(priority: .userInitiated) {
            guard let activity = Activity<TimerWidgetAttributes>.activities
                .first(where: { $0.id == activityID }) else {
                return
            }
            await activity.update(activityContent)
            
            // Send a second update after a short delay to force re-render
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await activity.update(activityContent)
        }
    }

    // MARK: - End
    func endLiveActivity() {
        guard let activityID else { return }
        self.activityID = nil
        
        Task.detached {
            guard let activity = Activity<TimerWidgetAttributes>.activities
                .first(where: { $0.id == activityID }) else { return }
            
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
    
    func startOrUpdate(displayName: String, endDate: Date, totalSeconds: Double, isRunning: Bool) {
        // Check if the stored activityID still has a live activity
        // If not, reset it so we start fresh
        if let id = activityID {
            let stillAlive = Activity<TimerWidgetAttributes>.activities.contains(where: { $0.id == id })
            if !stillAlive {
                activityID = nil  // ← reset stale ID
            }
        }
        
        if isActive {
            updateLiveActivity(displayName: displayName, endDate: endDate, isRunning: isRunning)
        } else {
            startLiveActivity(displayName: displayName, endDate: endDate, totalSeconds: totalSeconds, isRunning: isRunning)
        }
    }
    
    // MARK: - Start / Pause logic
    /// Start (or resume) the countdown.
    func start() {
        if !isRunning {
            // First start or resume: compute endDate from what's remaining now
            let remaining = endDate.timeIntervalSinceNow
            let effectiveRemaining = remaining > 0 ? remaining : totalSeconds
            
            self.endDate = Date().addingTimeInterval(effectiveRemaining)
            self.totalSeconds = effectiveRemaining
        }
        
        self.isRunning = true
        self.updateLiveActivity(endDate: self.endDate, isRunning: true)
    }
    
    /// Pause the countdown (keeps endDate so remaining time is preserved).
    func pause() {
        self.isRunning = false
        
        self.updateLiveActivity(endDate: self.endDate, isRunning: false)
    }
    func pause3() {
        self.isRunning = false
        guard let activityID else { return }

        // Compute frozen from current endDate
        let frozen = max(self.endDate.timeIntervalSinceNow, 0)

        let newState = TimerWidgetAttributes.ContentState(
            songTitle: self.displayName,
            isPlaying: false,
            endDate: self.endDate,
            totalDuration: self.totalSeconds,
            secondRemaining: frozen,
            frozenRemaining: frozen        // ← this switches ProgressBarView2 to static bar
        )
        let content = ActivityContent(state: newState, staleDate: Date()) // staleDate: Date() = urgent

        Task.detached(priority: .userInitiated) {
            guard let activity = Activity<TimerWidgetAttributes>.activities
                .first(where: { $0.id == activityID }) else { return }
            await activity.update(content)
        }
    }
    func pause2(endDate: Date? = nil, frozenRemaining: Double? = nil) async {
        guard let id = activityID,
              let activity = Activity<TimerWidgetAttributes>.activities.first(where: { $0.id == id })
        else { return }
        
        let updatedState = TimerWidgetAttributes.ContentState(
            songTitle: activity.content.state.songTitle,
            isPlaying: false,
            endDate: endDate ?? activity.content.state.endDate,
            totalDuration: activity.content.state.totalDuration,
            secondRemaining: frozenRemaining ?? activity.content.state.secondRemaining,
            frozenRemaining: frozenRemaining ?? activity.content.state.frozenRemaining
        )
        let content = ActivityContent(state: updatedState, staleDate: nil)
        await activity.update(content)
    }
    /// Pause the countdown — freezes the progress bar at current position
    func pauseFrozen(frozenRemaining: Double? = nil) {
        self.isRunning = false
        guard let activityID else { return }
        
        // Compute frozen value — use passed value, or derive from endDate
        let frozen = frozenRemaining ?? max(self.endDate.timeIntervalSinceNow, 0)
        
        let newState = TimerWidgetAttributes.ContentState(
            songTitle: self.displayName,
            isPlaying: false,
            endDate: self.endDate,
            totalDuration: self.totalSeconds,
            secondRemaining: frozen,
            frozenRemaining: frozen   // ← freezes ProgressBarView2
        )
        // Use a staleDate in the past to force immediate render on lock screen
        let activityContent = ActivityContent(state: newState, staleDate: Date())
        
        Task.detached(priority: .userInitiated) {
            guard let activity = Activity<TimerWidgetAttributes>.activities
                .first(where: { $0.id == activityID }) else { return }
            await activity.update(activityContent)
        }
    }
    
    /// Stop and finish (set remaining to 0).
    func stop() {
        self.endDate = Date()                  // now
        self.isRunning = false
        self.updateLiveActivity(endDate: self.endDate, isRunning: false)
    }

}
