//
//  NSMutableAttributedString.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/27/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

// Replaces ONLY the font size and leaves all other attributes in place (bold, italic, etc)

extension NSMutableAttributedString {
    func replaceFont(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let f = value as? UIFont, let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(.foregroundColor, range: range)
                    addAttribute(.foregroundColor, value: color, range: range)
                }
            }
        }
        endEditing()
    }
}
