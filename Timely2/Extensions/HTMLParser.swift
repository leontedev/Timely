//
//  HTMLParser.swift
//  Timely2
//
//  Created by Mihai Leonte on 1/10/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
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

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            //return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
            let attributedString = try NSAttributedString(data: data,
                      options: [.documentType: NSAttributedString.DocumentType.html,
                                .characterEncoding: String.Encoding.utf8.rawValue],
                      documentAttributes: nil)
            
            //Change the font, size and color only - but leave the other attributes in place (eg: bold, italic)
            let mutableAttrString = NSMutableAttributedString(attributedString: attributedString) as NSMutableAttributedString
            mutableAttrString.setFontFace(font: UIFont.systemFont(ofSize: 14), color: .darkGray)
            
            return mutableAttrString as NSAttributedString
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
