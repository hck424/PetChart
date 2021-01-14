//
//  Utility.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/27.
//

import UIKit
import AlamofireImage
class Utility: NSObject {
    class func isIphoneX() ->Bool {
        return ((AppDelegate.instance()?.window?.safeAreaInsets.bottom)! > 0.0)
    }
//    class func getUUID() ->String {
//        let uniqueDeviceId: String? = KeychainWrapper.standard.string(forKey: KeychainWrapper.Key.myKey.rawValue)
//
//        if let uuid = uniqueDeviceId {
//            return uuid
//        }
//
//        let uuidRef: CFUUID = CFUUIDCreate(nil)
//        let uuidStringRef: CFString = CFUUIDCreateString(nil, uuidRef)
//        let uuid:String = String(uuidStringRef)
//
//        let saveSuccessful: Bool = KeychainWrapper.standard.set(uuid, forKey:KeychainWrapper.Key.myKey.rawValue)
//        if saveSuccessful {
//            return uuid
//        }
//        return ""
//    }
    class func numberToString(num:Float) ->String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfEven
        formatter.numberStyle = .decimal
        return formatter.string(from: num as NSNumber)!
    }
}

//extension KeychainWrapper.Key {
//    static let myKey: KeychainWrapper.Key = "com.app.petchart"
//}


