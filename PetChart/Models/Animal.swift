//
//  Animal.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import AVKit
import ObjectMapper

struct AnimalType {
    let id: Int
    let dtype:String    //puppy, Cat, Etc
    let label:String    //강아지, 고양이, 기타
}
struct ImageInfo: Mappable {
    var id: Int?
    var itype:String?
    var thumbnail: String?
    var original: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        itype <- map["itype"]
        thumbnail <- map["thumbnail"]
        original <- map["original"]
    }
}
class Animal: Mappable {
    var petName: String?
    var is_main: String? //Y/N
    var birthday: String?
    var birthMonth: Int?
    var neutral: String?  //중성화 여부 중성화 여부 (Y|N|D) Y: 예, N: 아니오, D: 모름
    var size: String? //펫크기 (S|M|B)
    var dtype: String?
    var age: Int = 0
    var regist_id: String?
    var sex: String?
    var kind: String? //품종
    var images: Array<ImageInfo>?
    var id: Int?
    var prevention: String? //예방접종 여부 예방접종 여부 (Y|N|D) Y: 예, N: 아니오, D: 모름
    var weight: Int? //단위 g
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        petName <- map["petName"]
        is_main <- map["is_main"]
        birthday <- map["birthday"]
        neutral <- map["neutral"]
        size <- map["size"]
        dtype <- map["dtype"]
        age <- map["age"]
        regist_id <- map["regist_id"]
        sex <- map["sex"]
        kind <- map["kind"]
        images <- map["images"]
        id <- map["id"]
        prevention <- map["prevention"]
        weight <- map["weight"]
    }
}
