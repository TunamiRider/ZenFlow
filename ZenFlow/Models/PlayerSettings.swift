//
//  PlayerSettings.swift
//  ZenFlow
//
//  Created by Yuki Suzuki on 5/21/26.
//
import AVPlayerPlus
struct PlayerSettings {
    var selected: AVPlayerPlus.SoundResource = .crystalBowl
    var dingEnabled: Bool = true
    var dingInterval: Int = 1 //minutes
    
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

