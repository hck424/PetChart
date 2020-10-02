//
//  Constants.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import Foundation
import UIKit

let SERVER_PREFIX = "https://jayutest.best:5001"
//let SERVER_PRIFIX = "https://jayutest.best:5001"


typealias LoginClouser = (UserInfo?, Error?) -> Void
let ColorDefault = RGB(233, 95, 94)
public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}

let IsShowTutorial = "IsShowTutorial"
let KAKAO_NATIVE_APP_KEY = "f43c314ddcf1ce35e19935da750b7c8a"
let NAVER_URL_SCHEME = "naverlogin"
let NAVER_CONSUMER_KEY = "X7G9gqYulGWet9LR8V0k"
let NAVER_CONSUMER_SECRET = "DDdzjicyuS"
let kUSER_UUID = "USER_UUID"

