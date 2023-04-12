//
//  Colors.swift
//  Neuroginarium
//
//  Created by Станислава on 05.04.2023.
//

import UIKit

enum Colors: String, CaseIterable, Codable, Equatable {
    case darkBlue = "#104767"
    case yellow = "#FFEB94"
    case lightYellow = "#FBF3A0"
    case blue = "#A1D6E2"
    case white = "#e0eff0"
    case orange = "#F8A055"
    case lightOrange = "#FFCCAC"
    case lightBrown = "#dfbda0"
    case pink = "#8b7788"
    case lightPink = "#e2dde1"
    
    var uiColor: UIColor {
        return UIColor(rgb: self.rawValue)!
    }
}

