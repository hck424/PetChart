//
//  CTextView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit
import Foundation

@IBDesignable class CTextView: UITextView {
    public var placeholderLabel: UILabel?
    var myDelegate: UITextViewDelegate?
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            if borderWidth > 0 {setNeedsLayout()}
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            if borderColor != nil { setNeedsLayout()}
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius > 0 { setNeedsLayout()}
        }
    }
    
    @IBInspectable var insetTop: CGFloat = 0.0 {
        didSet {
            if insetTop > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetBottom: CGFloat = 0.0 {
        didSet {
            if insetBottom > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetLeft: CGFloat = 0.0 {
        didSet {
            if insetLeft > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetRigth: CGFloat = 0.0 {
        didSet {
            if insetRigth > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var placeHolderColor: UIColor = UIColor(white: 0.78, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeHolderString: String? {
        didSet {
            if placeHolderString != nil {
                setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.textContainer.lineFragmentPadding = 0.0
        self.textContainerInset = UIEdgeInsets.init(top: insetTop, left: insetLeft, bottom: insetBottom, right: insetRigth)
        if placeHolderString != nil {
            self.configurePlaceholderLabel()
        }
        
        if borderWidth > 0 && borderColor != nil {
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
        }
        
        if cornerRadius > 0 {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }
//    override var text: String! {
//        didSet {
//            textViewDidChange(self)
//        }
//    }
    func configurePlaceholderLabel() {
        
        placeholderLabel = UILabel()
        placeholderLabel?.font = font
        placeholderLabel?.textColor? = placeHolderColor
        placeholderLabel?.text = placeHolderString
        placeholderLabel?.numberOfLines = 0
        
        self.addSubview(placeholderLabel!)
        
        placeholderLabel?.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insetLeft).isActive = true
        placeholderLabel?.topAnchor.constraint(equalTo: self.topAnchor, constant: insetTop).isActive = true
        placeholderLabel?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: insetRigth).isActive = true
        placeholderLabel?.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: insetBottom).isActive = true
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel?.isHidden = !textView.text.isEmpty
//    }
    
}
 
