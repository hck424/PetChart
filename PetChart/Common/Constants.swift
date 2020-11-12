//
//  Constants.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import Foundation
import UIKit

let SERVER_PREFIX = "https://jayutest.best:5001"
let IOT_SERVER_PREFIX = "http://192.168.4.1:5001"

typealias LoginClosure = (UserInfo?, Error?) -> Void
let ColorDefault = RGB(233, 95, 94)
public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}

let NotiNameHitTestView = "HitTestView"

let IsShowTutorial = "IsShowTutorial"
let KAKAO_NATIVE_APP_KEY = "4945988ae0215607dd3e5c1add4b3dd3"
let KAKAO_REST_API_KEY = "4bcddca6187aca7ae52e4a306b1cab88" //주소 써치
let NAVER_URL_SCHEME = "com.app.petchart"
let NAVER_CONSUMER_KEY = "pnwBsZc4aq8weaOwidr8"
let NAVER_CONSUMER_TESTER_KEY = "wns7874"
let NAVER_CONSUMER_SECRET = "AiJpWSBgRw"


let kDrink = "Drink"
let kEat = "Eat"
let kWeight = "Weight"
let kFeces = "Feces"
let kWalk = "Walk"
let kMedical = "Medical"

let kSmartChartDrink = "SmartChartDrink"
let kSmartChartEat = "SmartChartEat"

let kTotalChartDrink = "TotalChartDrink"
let kTotalChartEat = "TotalChartEat"
let kTotalChartWeight = "TotalChartWeight"
let kTotalChartFeces = "TotalChartFeces"
let kTotalChartWalk = "TotalChartWalk"
let kTotalChartMedical = "TotalChartMedical"

let kPushSetting = "PushSetting"

let kAPPLECATION_UUID = "APPLECATION_UUID"
let kUserId = "UserId"
let kPToken = "PToken"
let kLoginType = "LoginType"
let kUserIdx = "UserIdx"
let kUserPassword = "UserPassword"
let TAG_LOADING_IMG = 99999
let kMainShowPetId = "MainShowPetId"
let kMainShowPetName = "MainShowPetName"

let kMyHomeWifiPassword = "MyHomeWifiPassword"
let kPushUserData = "PushUserData"
enum Gender : String {
    case mail = "M"
    case femail = "F"
    
    func displayValue() ->String {
        if self.rawValue == "M" {
            return "남"
        }
        else {
            return "여"
        }
    }
}

enum PetHealth: String {
    case drink = "drink"
    case eat = "eat"
    case weight = "weight"
    case feces = "feces"
    case walk = "walk"
    case medical = "medical"
    
    func value()->String {
        return self.rawValue
    }
    func udfHomeGraphKey() ->String {
        if self.rawValue == "drink" {
            return kDrink
        }
        else if self.rawValue == "eat" {
            return kEat
        }
        else if self.rawValue == "weight" {
            return kWeight
        }
        else if self.rawValue == "feces" {
            return kFeces
        }
        else if self.rawValue == "walk"  {
            return kWalk
        }
        else if self.rawValue == "medical" {
            return kMedical
        }
        return kDrink
    }
    func udfTotalChartKey() ->String {
        if self.rawValue == "drink" {
            return kTotalChartDrink
        }
        else if self.rawValue == "eat" {
            return kTotalChartEat
        }
        else if self.rawValue == "weight" {
            return kTotalChartWeight
        }
        else if self.rawValue == "feces" {
            return kTotalChartFeces
        }
        else if self.rawValue == "walk"  {
            return kTotalChartWalk
        }
        else if self.rawValue == "medical" {
            return kTotalChartMedical
        }
        return kTotalChartDrink
    }
    func udfSmartChartKey() ->String {
        if self.rawValue == "drink" {
            return kSmartChartDrink
        }
        else if self.rawValue == "eat" {
            return kSmartChartEat
        }
        return kSmartChartDrink
    }
    
    func koreanValue() -> String? {
        if self.rawValue == "drink" {
            return "음수"
        }
        else if self.rawValue == "eat" {
            return "식사"
        }
        else if self.rawValue == "weight" {
            return "체중"
        }
        else if self.rawValue == "feces" {
            return "배변"
        }
        else if self.rawValue == "walk"  {
            return "산책"
        }
        else if self.rawValue == "medical" {
            return "진료"
        }
        else {
            return nil
        }
    }
    func colorType() ->UIColor? {
        if self.rawValue == "drink" {
            return RGB(51, 150, 254)
        }
        else if self.rawValue == "eat" {
            return RGB(255, 168, 0)
        }
        else if self.rawValue == "weight" {
            return RGB(236, 86, 112)
        }
        else if self.rawValue == "feces" {
            return RGB(102, 77, 211)
        }
        else if self.rawValue == "walk"  {
            return RGB(103, 186, 6)
        }
        else if self.rawValue == "medical" {
            return RGB(62, 191, 172)
        }
        return nil
    }
    
    func markImage() -> UIImage? {
        if self.rawValue == "drink" {
            return UIImage(named: "ico_wather")
        }
        else if self.rawValue == "eat" {
            return UIImage(named: "ico_eat")
        }
        else if self.rawValue == "weight" {
            return UIImage(named: "ico_weight")
        }
        else if self.rawValue == "feces" {
            return UIImage(named: "ico_feces")
        }
        else if self.rawValue == "walk"  {
            return UIImage(named: "ico_walk")
        }
        else if self.rawValue == "medical" {
            return UIImage(named: "ico_medical")
        }
        return nil
    }
    
    func sliderImage() -> UIImage? {
        if self.rawValue == "drink" {
            return UIImage(named: "oval_blue")
        }
        else if self.rawValue == "eat" {
            return UIImage(named: "oval_yellow")
        }
        else if self.rawValue == "weight" {
            return UIImage(named: "oval_red")
        }
        else if self.rawValue == "feces" {
            return UIImage(named: "oval_navy")
        }
        else if self.rawValue == "walk"  {
            return UIImage(named: "oval_green")
        }
        else if self.rawValue == "medical" {
            return UIImage(named: "oval_light_blue")
        }
        return nil
    }
}

enum GraphType: String {
    case min = "min"
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
}

public struct Address {
    let addressName: String
    var postCode: String
    var roadAddr: String
    var jibunAddr: String
    var depthOneAddr: String
    var deptTwoAddr: String
    var deptThreeAddr: String
}

struct WifiInfo {
    public var interface:String?
    public var ssid:String?
    public var bssid:String?
    public var password:String?
    public var model:String?
}

let IOT_API_KEY = "QRpvmh2AgDeg0us4csAI9Kpb0Bn4CoPQ"
let kIOT_SESSION_KEY = "IOT_SESSION_KEY"

struct MyError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
