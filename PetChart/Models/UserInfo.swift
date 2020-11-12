//
//  UserInfo.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/28.
//

import UIKit
import ObjectMapper

class UserInfo: Mappable {
    
    var userId: String?
    var email: String?
    var name: String?
    var nickname: String?
    var joinType: String?
    var birthday: String?
    var gender: String?
    var profileImageUrl: String?
    
    var accessToken: String?
    var expiresIn: TimeInterval?
    var expiredAt: Date?
    var refreshToken: String?
    
    var termsserviceAgree: Bool?
    var privacyAgree: Bool?
    var marketingAgree: Bool?
    var privacy_term: Int = 0
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var country: String?
    var password: String?
    var phone: String?
    var street: String?
    var zipcode: Int?

    
    required init?(map: Map) {
        
    }
  
    func mapping(map: Map) {
        name    <- map["name"]
        nickname    <- map["nickname"]
        birthday    <- map["birthday"]
        email   <- map["email"]
        userId  <- map["id"]
        joinType   <- map["join_type"]
        gender <- map["sex"]
        addressLine1   <- map["address_line1"]
        addressLine2   <- map["address_line2"]
        city    <- map["city"]
        country <- map["country"]
        marketingAgree <- map["marketing_agree"]
        password    <- map["password"]
        phone   <- map["phone"]
        privacyAgree   <- map["privacy_agree"]
        street  <- map["street"]
        termsserviceAgree  <- map["termsservice_agree"]
        zipcode <- map["zipcode"]
        accessToken <- map["access_token"]
        privacy_term <- map["privacy_term"]
    }
    
    func description() -> String {
        var des = ""
        des = "name: \(name ?? "")\n"
        des.append("nickname: \(nickname ?? "")\n")
        des.append("birthday: \(birthday ?? "")\n")
        des.append("email: \(email ?? "")\n")
        des.append("userId: \(userId ?? "")\n")
        des.append("joinType: \(joinType ?? "")\n")
        des.append("gender: \(gender ?? "")\n")
        des.append("addressLine1: \(addressLine1 ?? "")\n")
        des.append("addressLine2: \(addressLine2 ?? "")\n")
        des.append("city: \(city ?? "")\n")
        des.append("country: \(country ?? "")\n")
        des.append("marketingAgree: \(marketingAgree ?? false)\n")
        des.append("password: \(password ?? "")\n")
        des.append("phone: \(phone ?? "")\n")
        des.append("privacyAgree: \(privacyAgree ?? false)\n")
        des.append("street: \(street ?? "")\n")
        des.append("termsserviceAgree: \(termsserviceAgree ?? false)\n")
        des.append("zipcode: \(zipcode ?? 0)\n")
        des.append("accessToken: \(accessToken ?? "")\n")
        return des
    }
}
