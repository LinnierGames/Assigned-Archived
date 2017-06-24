//
//  Categories.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/24/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

extension UITextField {
    
    open func setStyleToParagraph(withPlacehodlerText placeholder: String?, withInitalText text: String?) {
        self.autocorrectionType = .default
        self.autocapitalizationType = .words
        self.text = text
        self.placeholder = placeholder
        
    }
    
}
