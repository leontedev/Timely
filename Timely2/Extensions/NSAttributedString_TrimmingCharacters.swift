//
//  NSAttributedString_TrimmingCharacters.swift
//  Timely2
//
//  Created by Mihai Leonte on 2/2/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func trimmingCharacters(in characterSet: CharacterSet) -> NSAttributedString {
        
        let result = self as! NSMutableAttributedString
        
        while let range = result.string.rangeOfCharacter(from: characterSet), range.lowerBound == result.string.startIndex {
            
            let length = result.string.distance(from: range.lowerBound, to: range.upperBound)
            result.deleteCharacters(in: NSRange(location: 0, length: length))
            
        }
        
        while let range = result.string.rangeOfCharacter(from: characterSet, options: .backwards),
            
            range.upperBound == result.string.endIndex {
                let location = result.string.distance(from: result.string.startIndex, to: range.lowerBound)
                let length = result.string.distance(from: range.lowerBound, to: range.upperBound)
                result.deleteCharacters(in: NSRange(location: location, length: length))
        }
        
        return result
        
    }
}
