//
//  ZenFlowApp.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//

import SwiftUI
import AVPlayerPlus
import AVFoundation
@preconcurrency import ActivityKit

final class AppDelegate:NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Reset isPlaying state on termination
        let shared = UserDefaults(suiteName: "group.com.ysuzuki.ZenFlow")
        shared?.set(false, forKey: "isPlaying")
        shared?.synchronize()
        
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let group = DispatchGroup()
            for activity in Activity<TimerWidgetAttributes>.activities {
                group.enter()
                let a = activity
                Task { @Sendable in
                    await a.end(nil, dismissalPolicy: .immediate)
                    group.leave()
                }
            }
            group.wait()
            semaphore.signal()
        }
        semaphore.wait()
    }
}

@main
struct ZenFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            
            DeepDiveTimer()
                .onOpenURL { url in
                    if url.host == "resume" {
                        NotificationCenter.default.post(name: .init("ZenFlowResumeFromWidget")
                                                        , object: nil
                                                        ,userInfo: ["fromLockScreen": false])
                    }
                }
        }
    }
}
