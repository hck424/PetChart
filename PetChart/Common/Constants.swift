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

let NotiNameHitTestView = "HitTestView"


let IsShowTutorial = "IsShowTutorial"
let KAKAO_NATIVE_APP_KEY = "f43c314ddcf1ce35e19935da750b7c8a"
let NAVER_URL_SCHEME = "naverlogin"
let NAVER_CONSUMER_KEY = "X7G9gqYulGWet9LR8V0k"
let NAVER_CONSUMER_SECRET = "DDdzjicyuS"
let kUSER_UUID = "USER_UUID"

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

enum GraphType: Int {
    case day
    case week
    case month
}
