//
//  SchoolManager.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/30/22.
//

import Foundation
import SwiftUI

class SchoolManager: ObservableObject {
    
    static let shared = SchoolManager()
    
    @Published var school : String = "Lesley University"
    
    public func schoolPrimaryColor() -> Color {
        if self.school == "Boston University" {
            return Color(UIColor(named: "BostonUniversityPrimary")!)
        } else if self.school == "Lesley University" {
            return Color(UIColor(named: "LesleyUniversityPrimary")!)
        }
        return Color(UIColor.label)
    }
    
    
    
}
