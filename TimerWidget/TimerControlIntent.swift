//
//  TimerControlIntent.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 6/1/26.
//

//import AppIntents
//import WidgetKit
//
//struct TimerControlIntent: AppIntent {
//    static var title: LocalizedStringResource = "Control Timer"
//    static var description = IntentDescription("Start, pause, or restart the timer")
//    
//    @Parameter(title: "Action", default: .start)
//    var action: TimerAction
//    
//    enum TimerAction: String, AppEnum {
//        case start = "Start"
//        case pause = "Pause"
//        case newSession = "New Session"
//        
//        static var typeDisplayRepresentation: TypeDisplayRepresentation {
//            TypeDisplayRepresentation(name: "Timer Action")
//        }
//        
//        static var caseDisplayRepresentations: [TimerAction: DisplayRepresentation] {
//            [
//                .start: DisplayRepresentation(stringLiteral: "Start"),
//                .pause: DisplayRepresentation(stringLiteral: "Pause"),
//                .newSession: DisplayRepresentation(stringLiteral: "New Session")
//            ]
//        }
//    }
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        // Communicate with your app via UserDefaults or AppGroup
//        let defaults = UserDefaults(suiteName: "group.com.yourapp.timer")
//        defaults?.set(action.rawValue, forKey: "timerAction")
//        defaults?.synchronize()
//        
//        // Reload widget
//        WidgetCenter.shared.reloadAllTimelines()
//        
//        return .result()
//    }
//}


