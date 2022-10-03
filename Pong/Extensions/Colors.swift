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
    
    public struct richIndigoRedTint {
        static let fadedIndigo = Color(hex: "422680")
        static let midIndigo = Color(hex: "341671")
        static let deepIndigo = Color(hex: "280659")
        static let deepPurple = Color(hex: "660F56")
        static let midPink = Color(hex: "AE2D68")
        static let lightCoral = Color(hex: "F54952")
        static let indigoRedArray = [
            Color(hex: "130329"),
            Color(hex: "1d0441"),
            Color(hex: "280659"),
            Color(hex: "390c58"),
            Color(hex: "4a1158"),
            Color(hex: "5b1757"),
            Color(hex: "6c1c57"),
            Color(hex: "7d2256"),
            Color(hex: "8e2855"),
            Color(hex: "a02d55"),
            Color(hex: "b13354"),
            Color(hex: "c23854"),
            Color(hex: "d33e53"),
            Color(hex: "e44353"),
            Color(hex: "f54952")
        ]
    }
    
    public static var poshGold: Color {
        return Color(red: 255/255, green: 204/255, blue: 0/255)
    }
    
    public static var poshLightGold: Color {
        return Color(red: 255/255, green: 226/255, blue: 0/255)
    }
    
    public static var poshLightGreen: Color {
        return Color(red: 151/255, green: 255/255, blue: 138/255)
    }
    
    public static var poshDarkGreen: Color {
        return Color(red: 15/255, green: 163/255, blue: 30/255)
    }
    public static var poshDarkRed: Color {
        return Color(red: 176/255, green: 14/255, blue: 14/255)
    }
    public static var poshDarkPurple: Color {
        return Color(red: 111/255, green: 15/255, blue: 178/255)
    }
    
    public static var poshDarkGray: Color {
        return Color(red: 0/255, green: 0/255, blue: 0/255)
    }
    
    public static var poshLightGray: Color {
        return Color(red: 0/255, green: 0/255, blue: 0/255)
    }
    
    public static var poshLighterGray: Color {
        return Color(red: 29/255, green: 30/255, blue: 32/255)
    }
    
    public static var poshGlowGray: Color {
        return Color(red: 69/255, green: 69/255, blue: 69/255)
    }
    
    public static var tintedGray: Color {
        return Color(red: 29/255, green: 30/255, blue: 32/255)
    }
    
    public static var tintedDarkGray: Color {
        return Color(red: 14/255, green: 15/255, blue: 16/255)
    }
    
    public static var instagramPink: Color {
        return Color(red: 255/255, green: 64/255, blue: 129/255)
    }
    
    public static var poshPink: Color {
        return Color(red: 255/255, green: 0/255, blue: 251/255)
    }
    
    public static var poshBlue: Color {
        return Color(red: 0/255, green: 0/255, blue: 255/255)
    }
    
    public static var imagePickerGradient: Color {
        return Color(red: 153/255, green: 153/255, blue: 153/255)
    }
    
    public static var analyticsTicketGradient1: Color {
        return Color(red: 100/255, green: 125/255, blue: 238/255)
    }
    
    public static var analyticsTicketGradient2: Color {
        return Color(red: 127/255, green: 83/255, blue: 172/255)
    }
    
    public static var analyticsRevenueGradient1: Color {
        return Color(red: 128/255, green: 255/255, blue: 114/255)
    }
    
    public static var analyticsRevenueGradient2: Color {
        return Color(red: 126/255, green: 232/255, blue: 250/255)
    }
    
    public static var analyticsGenderFemaleGradient1: Color {
        return Color(red: 240/255, green: 142/255, blue: 252/255)
    }
    
    public static var analyticsGenderFemaleGradient2: Color {
        return Color(red: 238/255, green: 81/255, blue: 102/255)
    }
    
    public static var analyticsGenderMaleGradient1: Color {
        return Color(red: 9/255, green: 198/255, blue: 249/255)
    }
    
    public static var analyticsGenderMaleGradient2: Color {
        return Color(red: 4/255, green: 93/255, blue: 233/255)
    }
    
    public static var analyticsGenderUndetectedGradient1: Color {
        return Color(red: 103/255, green: 130/255, blue: 180/255)
    }
    
    public static var analyticsGenderUndetectedGradient2: Color {
        return Color(red: 177/255, green: 191/255, blue: 216/255)
    }
    
    public static var analyticsTicketTypesGradient1: Color {
        return Color(red: 251/255, green: 123/255, blue: 162/255)
    }
    
    public static var analyticsTicketTypesGradient2: Color {
        return Color(red: 252/255, green: 224/255, blue: 67/255)
    }
    
    public static var webListItemGradient1: Color {
        return Color(red: 0/255, green: 164/255, blue: 228/255)
    }
    
    public static var webListItemGradient2: Color {
        return Color(red: 214/255, green: 214/255, blue: 214/255)
    }
    
    public static var releaseNotesGradient1: Color {
        return Color(red: 235/255, green: 107/255, blue: 157/255)
    }
    
    public static var releaseNotesGradient2: Color {
        return Color(red: 238/255, green: 140/255, blue: 104/255)
    }
    
    public static var purplePinkGradient1: Color {
        return Color(red: 233/255, green: 117/255, blue: 168/255)
    }
    
    public static var purplePinkGradient2: Color {
        return Color(red: 114/255, green: 108/255, blue: 248/255)
    }
    
    public static var messageUsGradient1: Color {
        return Color(red: 72/255, green: 195/255, blue: 235/255)
    }
    
    public static var messageUsGradient2: Color {
        return Color(red: 113/255, green: 142/255, blue: 221/255)
    }
    
    public static var viewEventsGradient1: Color {
        return Color(red: 168/255, green: 139/255, blue: 235/255)
    }
    
    public static var viewEventsGradient2: Color {
        return Color(red: 248/255, green: 206/255, blue: 236/255)
    }
    
    public static var trackingLinksRevenueGradient1: Color {
        return Color(red: 152/255, green: 222/255, blue: 91/255)
    }
    
    public static var trackingLinksRevenueGradient2: Color {
        return Color(red: 8/255, green: 225/255, blue: 174/255)
    }

    public static var guestListGradient1: Color {
        return Color(red: 219/255, green: 104/255, blue: 133/255)
    }
    
    public static var guestListGradient2: Color {
        return Color(red: 151/255, green: 34/255, blue: 57/255)
    }
    
    public static var poshLightBlueGradient1: Color {
        return Color(red: 131/255, green: 234/255, blue: 241/255)
    }
    
    public static var poshLightBlueGradient2: Color {
        return Color(red: 99/255, green: 164/255, blue: 255/255)
    }
    
    public static var trackingLinksGradient1: Color {
        return Color(red: 255/255, green: 241/255, blue: 148/255)
    }
    
    public static var trackingLinksGradient2: Color {
        return Color(red: 251/255, green: 176/255, blue: 52/255)
    }
    
    public static var payoutPendingGradient1: Color {
        return Color(red: 189/255, green: 189/255, blue: 189/255)
    }
        
    public static var payoutPendingGradient2: Color {
        return Color(red: 153/255, green: 153/255, blue: 153/255)
    }
    
    public static var complimentaryTicketsGradient1: Color {
        return Color(red: 9/255, green: 32/255, blue: 63/255)
    }
    
    public static var complimentaryTicketsGradient2: Color {
        return Color(red: 83/255, green: 120/255, blue: 149/255)
    }
    
    public static var reviewGradient1: Color {
        return Color(red: 255/255, green: 221/255, blue: 0/255)
    }
    
    public static var reviewGradient2: Color {
        return Color(red: 251/255, green: 176/255, blue: 52/255)
    }
    
    public static var superLightGray: Color {
        return Color(red: 240/255, green: 240/255, blue: 240/255)
    }
    
    public static var silver: Color {
        return Color(red: 192/255, green: 192/255, blue: 192/255)
    }
    
    public static var bronze: Color {
        return Color(red: 176/255, green: 141/255, blue: 87/255)
    }
    
    public static var lennonsPlaylist1: Color {
        return Color(hex: "#9795EF")
    }
    
    public static var lennonsPlaylist2: Color {
        return Color(hex: "#F9C5D1")
    }
    
    public static var codeLecture1: Color {
        return Color(hex: "#FB8085")
    }
    
    public static var codeLecture2: Color {
        return Color(hex: "#F9C1B1")
    }
    
    public static var earlyPeriod1: Color {
        return Color(hex: "#FF748B")
    }
    
    public static var earlyPeriod2: Color {
        return Color(hex: "#FE7BB0")
    }
    
    public static var sunburn1: Color {
        return Color(hex: "#F08EFC")
    }
    
    public static var sunburn2: Color {
        return Color(hex: "#EE5166")
    }
    
    public static var scientificLie1: Color {
        return Color(hex: "#E975A8")
    }
    
    public static var scientificLie2: Color {
        return Color(hex: "#726CF8")
    }
    
    public static var organicSearch1: Color {
        return Color(hex: "#FE0944")
    }
    
    public static var organicSearch2: Color {
        return Color(hex: "#FEAE96")
    }
    
    public static var bone: Color {
        return Color(red: 215/255, green: 210/255, blue: 203/255)
    }
    
    public static var pongSystemBackground : Color {
        return Color(red: 26/255, green: 26/255, blue: 26/255)
    }
    
}


