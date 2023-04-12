//
//  UIColor.swift
//  Neuroginarium
//
//  Created by Станислава on 05.04.2023.
//

import UIKit

extension UIColor {
    
    static func subString(str: String, startIndex: Int, endIndex: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: startIndex)
        let end = str.index(str.startIndex, offsetBy: endIndex)
        let range = start ..< end
        return String(str[range])
    }
    
    convenience init?(rgb: String) {
        let str = rgb.filter { $0 != "#" }
        if str.count != 6 {
            return nil
        }
        
        let redHex = Self.subString(str: str, startIndex: 0, endIndex: 2)
        let greenHex = Self.subString(str: str, startIndex: 2, endIndex: 4)
        let blueHex = Self.subString(str: str, startIndex: 4, endIndex: 6)
        
        if let red = Int(redHex, radix: 16),
           let green = Int(greenHex, radix: 16),
           let blue = Int(blueHex, radix: 16) {
            self.init(
                red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                blue: CGFloat(blue) / 255.0,
                alpha: 1
            )
        } else {
            return nil
        }
    }
    
    func cgcolor() -> CGColor {
        return self.cgColor
    }
}

