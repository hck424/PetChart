//
//  ApiManager.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

class ApiManager: NSObject {
    static let shared = ApiManager()
    
   //로그인
    func requestUserSignIn(param: [String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared .post("/api/v1/signin", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    //회원가입
    func requestUserSignOut(param:[String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared .post("/api/v1/signup", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
}
