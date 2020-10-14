//
//  Extension.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import Foundation
import UIKit
//FIXME:: UITableView
extension UITableView {
    func reloadData(completion:@escaping ()-> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { (finish) in
            completion()
        }
    }
}

//FIXME:: UIViewController
extension UIViewController {
    
    func showErrorAlertView(_ data: Any?) {
        if let data = data as? Dictionary<String, Any> {
            
            var title = "에러"
            if let code = data["code"] as? Int {
                title.append(":\(code)")
            }
            
            guard let msg = data["msg"] as? String else {
                return
            }
            AlertView.showWithOk(title: nil, message: msg, completion: nil)
            
        }
        else if let data = data as? Error {
//            AlertView.showWithOk(title: "Error", message: "시스템에러", completion: nil)
        }
    }
}
//FIXME:: UIView
extension UIView {
    func addShadow(offset:CGSize, color:UIColor, raduius: Float, opacity:Float) {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = CGFloat(raduius)
        self.layer.shadowOpacity = opacity
        
        let bgColor = self.backgroundColor
        self.backgroundColor = nil
        self.layer.backgroundColor = bgColor?.cgColor
    }
    
    func startAnimation(raduis: CGFloat) {
        let imageName = "ico_loading"

        let indicator = viewWithTag(TAG_LOADING_IMG) as? UIImageView
        if indicator != nil {
            indicator?.removeFromSuperview()
        }

        isHidden = false
        superview?.bringSubviewToFront(self)

        let ivIndicator = UIImageView(frame: CGRect(x: 0, y: 0, width: 2 * raduis, height: 2 * raduis))
        ivIndicator.tag = TAG_LOADING_IMG
        ivIndicator.contentMode = .scaleAspectFit
        ivIndicator.image = UIImage(named: imageName)
        addSubview(ivIndicator)
        indicator?.layer.borderWidth = 1.0
        indicator?.layer.borderColor = UIColor.red.cgColor
        ivIndicator.frame = CGRect(x: (frame.size.width - ivIndicator.frame.size.width) / 2, y: (frame.size.height - ivIndicator.frame.size.height) / 2, width: ivIndicator.frame.size.width, height: ivIndicator.frame.size.height)

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: -2.0 * Double(CGFloat.pi))
        rotation.duration = 1
        rotation.repeatCount = .infinity

        ivIndicator.layer.add(rotation, forKey: "loading")
    }
    func stopAnimation() {
        isHidden = true
        let indicator = viewWithTag(TAG_LOADING_IMG) as? UIImageView
        if indicator != nil {
            indicator?.layer.removeAnimation(forKey: "loading")
            //        [indicator removeFromSuperview];
        }
    }
}
//FIXME:: CACornerMask
extension CACornerMask {
    init(TL: Bool = false, TR: Bool = false, BL: Bool = false, BR: Bool = false) {
        var value: UInt = 0
        if TL { value += 1 }
        if TR { value += 2 }
        if BL { value += 4 }
        if BR { value += 8 }

        self.init(rawValue: value)
    }
}
extension UIColor {
    convenience init(hex: UInt) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}
//FIXME:: UIImage
extension UIImage {
    
    class func image(from color: UIColor?) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if let cg = color?.cgColor {
            context?.setFillColor(cg)
        }
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
//FIXME:: Error
public extension Error {
    var localizedDescription: String {
        return NSError(domain: _domain, code: _code, userInfo: nil).localizedDescription
    }
}

//FIXME:: String
extension String {
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
    func deletingPrefix(_ prefix: String) -> String {
           guard self.hasPrefix(prefix) else { return self }
           return String(self.dropFirst(prefix.count))
    }
    // String Trim
    public var stringTrim: String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // Return String chracters count
    public var length: Int {
        return self.count
    }
    
    // String localized
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    // String localized with comment
    public func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, comment:comment)
    }
    
    // E-mail address validation
    public func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    
    // Password validation
    public func validatePassword() -> Bool {
        let passwordRegEx = "(?=.*[a-zA-Z])(?=.*[!@#$%^_*-])(?=.*[0-9]).{8,40}"
            //"^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,16}$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    
    // String split return array
    public func arrayBySplit(splitter: String? = nil) -> [String] {
        if let s = splitter {
            return self.components(separatedBy: s)
        } else {
            return self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        }
    }
    
    func validateKorPhoneNumber(_ candidate: String?) -> Bool {
        let emailRegex = "^[0-9]{3}+[0-9]{4}+[0-9]{4}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: candidate)
    }
}
