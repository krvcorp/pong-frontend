//
//  LeaderboardAwardCoin.swift
//  Pong
//
//  Created by Pranav Ramesh on 8/18/22.
//

import SwiftUI

struct LeaderboardAwardCoin: View {
    
    var score: Int?
    var nickname: String?
    var place: Int?
    
    private var glyph: String {
        "\(place ?? 0)place_medal"
    }
    
    private var gradient: LinearGradient {
        switch place {
        case 1: return LinearGradient(colors: [Color(red: 255/255, green: 245/255, blue: 245/255), Color(red: 255/255, green: 209/255, blue: 220/255)], startPoint: .top, endPoint: .bottom)
        case 2: return LinearGradient(colors: [Color(red: 245/255, green: 245/255, blue: 255/255), Color(red: 198/255, green: 225/255, blue: 242/255)], startPoint: .top, endPoint: .bottom)
        case 3: return LinearGradient(colors: [Color(red: 245/255, green: 255/255, blue: 245/255), Color(red: 180/255, green: 219/255, blue: 206/255)], startPoint: .top, endPoint: .bottom)
        default: return LinearGradient(colors: [Color(red: 245/255, green: 245/255, blue: 245/255), Color(red: 210/255, green: 210/255, blue: 210/255)], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private var shadowColor: Color {
        let op: Double = 0.4
        switch place {
        case 1: return Color(red: 200/255, green: 180/255, blue: 180/255, opacity: op)
        case 2: return Color(red: 180/255, green: 180/255, blue: 200/255, opacity: op)
        case 3: return Color(red: 160/255, green: 180/255, blue: 160/255, opacity: op)
        default: return Color(red: 200/255, green: 200/255, blue: 200/255, opacity: op)
        }
    }

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(gradient)
                    .shadow(color: shadowColor, radius: 8, x: 0, y: 6)
                Image(glyph)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .opacity((1...3).contains(place ?? 0) ? 1 : 0.25)
            }
            .frame(width: 96, height: 96)
            
            VStack {
                Text(place != nil ? "\(score!)" : " ")
                    .fontWeight(.semibold)
                    .italic()
                    .frame(maxWidth: 96)
                
                Text(place != nil ? "\(nickname!)" : " ")
                    .fontWeight(.semibold)
                    .italic()
                    .frame(maxWidth: 96)
            }
        }
    }
}

struct LeaderboardAwardCoin_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardAwardCoin(score: 4241, place: 1)
    }
}
