//
//  Fonts.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit

public struct Fonts {
    static let primaryFont = Fonts.getHiraginoSansFont(fontSize: 16, fontWeight: .regular)
    static let primaryBoldFont = Fonts.getHiraginoSansFont(fontSize: 16, fontWeight: .bold)
}

public extension Fonts {
    
    private struct FontNames {
        static let hiraginoSansRegular = "HiraginoSans-W3"
        static let hiraginoSansBold = "HiraginoSans-W6"
    }

    public static func getFont(fontSize: CGFloat, fontWeight: UIFont.Weight) -> UIFont {
        return Fonts.getHiraginoSansFont(fontSize: fontSize, fontWeight: fontWeight)
    }
    
    public static func getHiraginoSansFont(fontSize: CGFloat, fontWeight: UIFont.Weight) -> UIFont {
        if fontWeight == .bold {
            return UIFont(name: FontNames.hiraginoSansBold, size: fontSize) ?? UIFont.systemFont(ofSize: CGFloat(Settings.fontSize.value), weight: .bold)
        } else {
            return UIFont(name: FontNames.hiraginoSansRegular, size: fontSize) ?? UIFont.systemFont(ofSize: CGFloat(Settings.fontSize.value), weight: .regular)
        }
    }
}
