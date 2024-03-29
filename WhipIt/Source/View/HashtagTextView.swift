//
//  HashtagTextView.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import UIKit

final class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    
    func resolveHashTags() {
        self.isEditable = false
        self.isSelectable = true
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))

        hashtagArr = results?.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
                                
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: [.caseInsensitive, .backwards])
                                                                
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    i += 1
                }
            }
        }
        
        attrString.addAttributes([.font: UIFont(name: Suit.light, size: 15)!], range: NSRange(location: 0, length: nsText.length))

        self.attributedText = attrString
    }
}
