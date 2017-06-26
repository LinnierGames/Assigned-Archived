//
//  Constants.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/25/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

func CTAttributedStringStrikeOut(string: String) -> NSMutableAttributedString {
    let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: string)
    attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
    return attributeString
}
