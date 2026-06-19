//
//  PlayerSettings.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//
import AVPlayerPlus
import SwiftData
import Foundation
struct PlayerSettings {
    var selected: AVPlayerPlus.SoundResource = .crystalBowl
    var dingEnabled: Bool = true
    var dingInterval: Int = 1 //minutes
    var duration: Int = 5
    var isWidgetOn: Bool = true
    
    
    static func load() -> PlayerSettings {
        let savedResource = UserDefaults.standard.string(forKey: "resourceName").flatMap{ AVPlayerPlus.SoundResource(rawValue: $0) }
        ?? .crystalBowl
        
        let dingEnabled = UserDefaults.standard.object(forKey: "dingEnabled") as? Bool ?? true
        
        var dingInterval = UserDefaults.standard.integer(forKey: "dingInterval")
        if dingInterval == 0 {
            dingInterval = 1
            UserDefaults.standard.set(1, forKey: "dingInterval")
        }
        
        var duration = UserDefaults.standard.integer(forKey: "duration")
        if duration == 0 {
            duration = 5
            UserDefaults.standard.set(5, forKey: "duration")
        }
        
        let isWidgetOn = UserDefaults.standard.object(forKey: "isWidgetOn") as? Bool ?? true
        
        return PlayerSettings(selected: savedResource, dingEnabled: dingEnabled, dingInterval: dingInterval,duration: duration, isWidgetOn: isWidgetOn)

    }
    
    func save(){
        UserDefaults.standard.set(selected.resourceName, forKey: "resourceName")
        UserDefaults.standard.set(dingEnabled, forKey: "dingEnabled")
        UserDefaults.standard.set(dingInterval, forKey: "dingInterval")
        UserDefaults.standard.set(duration, forKey: "duration")
        UserDefaults.standard.set(isWidgetOn, forKey: "isWidgetOn")
    }
    
    var totalSeconds: Int {
        dingInterval * 60
    }
    
    var backgroundImagePath: String {
        switch self.selected {
        case .deepOcean:
            return "deepOcean"
        case .rainDrizzleThunder:
            return "rainThunder"
        case .seasideRocksShore:
            return "seasideShore"
        case .seaLagoonWaves:
            return "lagoonBeach"
        case .underWaterRain:
            return "underwaterRain"
        case .underwaterWhaleDiving:
            return "whaleDiving"
        case .crystalBowl:
            return "crystalBowl"
        case .modernSutra:
            return "modernSutra"
        }
        
    }
}

