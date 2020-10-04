//
//  AlertView.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/27.
//

import UIKit

enum AlertViewType: Int {
    case normal
    case optionalBox
}

typealias AlertClosure = (Int) -> Void
let TAG_ALERT_VIEW = 10111

class AlertView: UIView {
    
    @IBOutlet var xib: UIView!
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var svBtnContainer: UIStackView!
    @IBOutlet weak var svButton: UIStackView!
    

    var title: Any?
    var message: Any?
    var btnTitles: Array<Any>?
    var completion:AlertClosure?
    var btnTitleColor: Array<UIColor>?
    var type: AlertViewType = .normal
    var optionBtnTitles: Array<Any>?
    
    class func showWithOk(title:Any?, message: Any?, completion:AlertClosure?) {
        let titles = ["확인"]
        let alert = AlertView.init(title: title, message: message, btnTitles:titles , completion: completion)
        
        alert.btnTitleColor = [RGB(233, 95, 94)]
        alert.show()
    }
    
    class func showWithCancelAndOk(title:Any?, message: Any?, completion:AlertClosure?) {
        let titles = ["취소", "확인"]
        let alert = AlertView.init(title: title, message: message, btnTitles:titles , completion: completion)
        
        alert.btnTitleColor = [RGB(136, 136, 136), RGB(233, 95, 94)]
        alert.show()
    }
    
    class func showWithCancelAndOk(title:Any?, message: Any?, optionBtnTitles:Array<Any>?,  completion:AlertClosure?) {
        let titles = ["취소", "확인"]
        let alert = AlertView.init(title: title, message: message, btnTitles:titles , completion: completion)
        alert.type = .optionalBox
        alert.optionBtnTitles = optionBtnTitles
        alert.btnTitleColor = [RGB(136, 136, 136), RGB(233, 95, 94)]
        alert.show()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    convenience init(title: Any?, message: Any?, btnTitles: [AnyHashable]?, completion: AlertClosure?) {
        self.init(frame: UIScreen.main.bounds)
        self.title = title
        self.message = message
        self.btnTitles = btnTitles
        self.completion = completion
        
        loadXib()
    }
    
    func loadXib() {
        xib = Bundle(for: Swift.type(of: self)).loadNibNamed("AlertView", owner: self, options: nil)?.first as? UIView
        self.addSubview(xib)
        xib.translatesAutoresizingMaskIntoConstraints = false
        
        xib.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        xib.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        xib.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        xib.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
    func show() {
        self.backgroundColor = UIColor.clear
        let window = AppDelegate.instance()?.window
        
        if let view:UIView = window?.viewWithTag(TAG_ALERT_VIEW) {
            view.removeFromSuperview()
        }
        
        window?.addSubview(self)
        self.tag = TAG_ALERT_VIEW
        self.configurationUi()
        xib.backgroundColor = UIColor.clear
        containerView.alpha = 0.0
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.xib.backgroundColor = RGBA(0, 0, 0, 0.2)
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.containerView.alpha = 1.0
            
        } completion: { (finish) in
            
        }
    }
    
    func makeButton(tag: Int) ->UIButton {
        let index = tag-1000
        let title = btnTitles?[index]
        let titleColor = btnTitleColor?[index]
        
        let button = UIButton(type: .custom)
        button.setTitleColor(titleColor, for: .normal)
        if let title: String = title as? String {
            button.setTitle(title, for: .normal)
        }
        else if let title: NSAttributedString = title as? NSAttributedString {
            button.setAttributedTitle(title, for: .normal)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = UIColor.white
        button.tag = tag
        
        return button
    }
    
    func makeOptionButton(tag: Int) ->UIButton {
        let index = tag - 100
        let title = optionBtnTitles?[index]
        
        let button = UIButton(type: .custom)
        button.setTitleColor(RGB(0, 0, 0), for: .normal)
        if let title: String = title as? String {
            button.setTitle(title, for: .normal)
        }
        else if let title: NSAttributedString = title as? NSAttributedString {
            button.setAttributedTitle(title, for: .normal)
        }
        button.contentHorizontalAlignment = .left
        button.setImage(UIImage(named: "radio_off"), for: .normal)
        button.setImage(UIImage(named: "radio_on"), for: .selected)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.backgroundColor = UIColor.white
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.adjustsImageWhenHighlighted = false
//        button.layer.borderColor = UIColor.red.cgColor
//        button.layer.borderWidth = 1.0
        button.tag = tag
        return button
    }
    
    func configurationUi() {
        self.containerView.layer.cornerRadius = 20
        self.containerView.clipsToBounds = true
        if let title = title {
            svTitle.isHidden = false
            if let title:String = title as? String {
                lbTitle.text = title
            }
            else if let title:NSAttributedString = title as? NSAttributedString {
                lbTitle.attributedText = title
            }
        }
        else {
            svTitle.isHidden = true
        }
        
        if let message = message {
            svContent.isHidden = false
            if let message:String = message as? String {
                lbMsg.text = message
            }
            else if let message:NSAttributedString = message as? NSAttributedString {
                lbMsg.attributedText = message
            }
        }
        else {
            svContent.isHidden = true
        }
        
        if let optionBtnTitles = optionBtnTitles {
            svContent.isHidden = false
            let svOption = UIStackView.init()
            svOption.axis = NSLayoutConstraint.Axis.vertical
            svOption.distribution = UIStackView.Distribution.fillEqually
            svOption.isLayoutMarginsRelativeArrangement = true
            svOption.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            svContent.addArrangedSubview(svOption)
            for i in 0..<optionBtnTitles.count {
                let btn = self.makeOptionButton(tag: 100+i)
                svOption.addArrangedSubview(btn)
                btn.addTarget(self, action: #selector(onClickedButtonActions(_:)), for: .touchUpInside)
            }
        }
        
        if let btnTitles = btnTitles {
            svBtnContainer.isHidden = false
            for i in 0..<btnTitles.count {
                let btn = self.makeButton(tag: 1000+i)
                svButton.addArrangedSubview(btn)
                btn.addTarget(self, action: #selector(onClickedButtonActions(_:)), for: .touchUpInside)
            }
        }
        else {
            svBtnContainer.isHidden = true
        }
    }
    
    @objc @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if (sender == btnFullClose) {
            self.dismiss()
        }
        else if sender.tag >= 1000 {
            if type == .optionalBox {
                if sender.tag == 1001 {
                    var optionIndex: Int = -1
                    for i in 0..<optionBtnTitles!.count {
                        let subview = svContent.viewWithTag(100+i)
                        if let btn:UIButton = subview as? UIButton {
                            if btn.isSelected {
                                optionIndex = btn.tag - 100
                            }
                        }
                    }
                    
                    if optionIndex >= 0 {
                        completion?(optionIndex)
                    }
                }
            }
            else {
                completion?(sender.tag - 1000)
            }
            self.dismiss()
        }
        else if (sender.tag >= 100) {
            for i in 0..<optionBtnTitles!.count {
                let subview = svContent.viewWithTag(100+i)
                if let btn:UIButton = subview as? UIButton {
                    btn.isSelected = false
                }
            }
            sender.isSelected = true
        }
    }
    
    func dismiss() {
        self.completion = nil
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.xib.backgroundColor = UIColor.clear
            self.containerView.alpha = 0.0
            self.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { (finish) in
            self.removeFromSuperview()
        }
   }
}
