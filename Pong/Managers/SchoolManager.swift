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
    
    @Published var school : String = "Boston University"
    
    public func schoolPrimaryColor() -> Color {
        if self.school == "Boston University" {
            return Color(UIColor(named: "BostonUniversityPrimary")!)
        }
        return Color(UIColor.label)
    }
    
    
    
}
