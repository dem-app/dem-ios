//
//  InputView.swift
//  MTC App
//
//  Created by Vijay on 02/06/18.
//  Copyright © 2018 vijay kumar. All rights reserved.
//

import UIKit

@IBDesignable
class InputView: UIView {
    
    var shadowcolor = UIColor(red: 0/255, green: 96/255, blue: 64/255, alpha: 1.0).cgColor
    var shadowopacity: Float = 0.1
    var bordercolor = UIColor(red: 0/255, green: 96/255, blue: 64/255, alpha: 0.1).cgColor
    
    @IBInspectable var cornerradius: CGFloat =  25 { didSet { layoutSubviews() }}
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerradius
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: cornerradius, height: cornerradius))
        
        layer.masksToBounds = false
        layer.shadowColor = shadowcolor
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = shadowopacity
        layer.shadowPath = shadowPath.cgPath
        layer.shadowRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = bordercolor
    }

}
