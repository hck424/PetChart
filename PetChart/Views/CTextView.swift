//
//  CTextView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit
import Foundation

@IBDesignable class CTextView: UITextView, UITextViewDelegate {
    private var placeholderLabel: UILabel?
    
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
    
    @IBInspectable var insetTB: CGFloat = 0.0 {
        didSet {
            if insetTB > 0.0 { setNeedsDisplay() }
        }
    }
    @IBInspectable var insetLR: CGFloat = 0.0 {
        didSet {
            if insetLR > 0.0 { setNeedsDisplay() }
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
        self.textContainerInset = UIEdgeInsets.init(top: insetTB, left: insetLR, bottom: insetTB, right: insetLR)
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
    override var text: String! {
        didSet {
            textViewDidChange(self)
        }
    }
    func configurePlaceholderLabel() {
        self.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel?.font = font
        placeholderLabel?.textColor? = placeHolderColor
        placeholderLabel?.text = placeHolderString
        placeholderLabel?.numberOfLines = 0
        
        self.addSubview(placeholderLabel!)
        
        placeholderLabel?.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insetLR).isActive = true
        placeholderLabel?.topAnchor.constraint(equalTo: self.topAnchor, constant: insetTB).isActive = true
        placeholderLabel?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: insetLR).isActive = true
        placeholderLabel?.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: insetTB).isActive = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
}
 
