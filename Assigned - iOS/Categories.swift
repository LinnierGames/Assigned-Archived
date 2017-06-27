//
//  Categories.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/24/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

public let CTDisabledOpeque: CGFloat = 0.45
public let CTDisabledColor = UIColor.darkGray

extension UITableViewCell {
    func setState(enabled: Bool) {
        if enabled {
            self.textLabel!.alpha = 1
            self.detailTextLabel!.alpha = 1
            self.isUserInteractionEnabled = true
        } else {
            self.textLabel!.alpha = 0.3
            self.detailTextLabel!.alpha = 0.3
            self.isUserInteractionEnabled = false
        }
    }
}

extension UITextField {
    open func setStyleToParagraph(withPlacehodlerText placeholder: String?, withInitalText text: String?) {
        self.autocorrectionType = .default
        self.autocapitalizationType = .words
        self.text = text
        self.placeholder = placeholder
        
    }
    
}

extension UIAlertController {
    var inputField: UITextField {
        return self.textFields!.first!
    }
    
}
