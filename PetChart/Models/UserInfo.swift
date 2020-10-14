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
    
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var country: String?
    var marketingAgree: Bool?
    var password: String?
    var phone: String?
    var privacyAgree: Bool?
    var street: String?
    var termsserviceAgree: Bool?
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
    }
}
