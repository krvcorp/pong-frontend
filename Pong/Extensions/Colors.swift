import Foundation
import SwiftUI
import AVFAudio
import AVFoundation

extension Color {
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    public static var bone: Color {
        return Color(red: 215/255, green: 210/255, blue: 203/255)
    }
    
    public static var pongSystemBackground : Color {
        return Color(UIColor(named: "pongSystemBackground")!)
    }
    
    public static var pongSecondarySystemBackground : Color {
        return Color(UIColor(named: "pongSecondarySystemBackground")!)
    }
    
    public static var pongLabel : Color {
        return Color(UIColor(named: "pongLabel")!)
    }
    
    public static var pongAccent : Color {
        return Color(UIColor(named: "pongAccent")!)
    }
    
    public static var lesleyUniversityPrimary : Color {
        return Color(UIColor(named: "LesleyUniversityPrimary")!)
    }
    
    public static var bostonUniversityPrimary : Color {
        return Color(UIColor(named: "BostonUniversityPrimary")!)
    }
    
    public static var notificationUnread : Color {
        return Color(UIColor(named: "notificationUnread")!)
    }
    
    public static var pongSecondaryText : Color {
        return Color(UIColor(named: "pongSecondaryText")!)
    }

    public static var pongGray: Color {
        return Color(red: 217/255, green: 218/255, blue: 219/255)
    }
    
    public static var pongSystemWhite: Color {
        return Color(UIColor(named: "pongSystemWhite")!)
    }

}


