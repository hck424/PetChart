//
//  Animal.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import AVKit

struct AnimalType {
    let id: Int
    let dtype:String    //puppy, Cat, Etc
    let label:String    //강아지, 고양이, 기타
}

class Animal: NSObject {
    var name: String?
    var profileImage: UIImage?
    var profileImageOrigin: UIImage?
    var animalType:AnimalType?
    var kind: String? //종류
    var item: String? //품종
    var birthday: String? //생년월일
    var gender: String?
    var neutral: String?  //중성화 여부 중성화 여부 (Y|N|D) Y: 예, N: 아니오, D: 모름
    var prevent: String? //예방접종 여부 예방접종 여부 (Y|N|D) Y: 예, N: 아니오, D: 모름
    var size:String? //펫크기 (S|M|B)
    var regiNumber: String? //등록번호
    var age: Int = 0
    var sex:Gender? //
}
