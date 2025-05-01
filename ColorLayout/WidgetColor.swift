//
//  WidgetColor.swift
//  ColorLayout
//
//  Created by wanghong on 2025/04/30.
//

import SwiftUI

enum WidgetColor: CaseIterable, Equatable {
    case skyBlue, hotPink, brightYellow, limeGreen, vibrantOrange

    var color: Color {
        switch self {
        case .skyBlue:
            return Color(hex: 0x00CFFF)
        case .hotPink:
            return Color(hex: 0xFF5C93)
        case .brightYellow:
            return Color(hex: 0xFFEB3B)
        case .limeGreen:
            return Color(hex: 0xAEEA00)
        case .vibrantOrange:
            return Color(hex: 0xFF6D00)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        let red   = Double((hex & 0xFF0000) >> 16) / 255
        let green = Double((hex & 0x00FF00) >> 8 ) / 255
        let blue  = Double( hex & 0x0000FF       ) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

