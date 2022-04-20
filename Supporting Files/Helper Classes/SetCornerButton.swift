//
//  SetCornerButton.swift

//  Created by Devansh on 06/ .
//  Copyright © 2017 Devansh. All rights reserved.
//

import UIKit

@IBDesignable
class SetCornerButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            setCorner()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            setCorner()
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            setCorner()
        }
    }
    
    func setCorner() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
    }
    
    override open func prepareForInterfaceBuilder() {
        setCorner()
    }
}
