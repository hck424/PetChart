//
//  KakaoController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/28.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class KakaoController: NSObject {
    var completion:LoginClosure?
    var user:UserInfo?
    func login(viewcontorller: UIViewController, completion:LoginClosure?) {
        self.completion = completion
        if AuthApi.isKakaoTalkLoginAvailable() {
            AuthApi.shared.loginWithKakaoTalk { (token: OAuthToken?, error:Error?) in
                if let error = error {
                    print(error)
                    self.completion?(nil, nil)
                    return
                }
                print("login kakaotalk success.")
                self.user = UserInfo.init(JSON: ["access_token": token?.accessToken ?? ""])
                self.user?.expiresIn = token?.expiresIn
                self.user?.expiredAt = token?.expiredAt
                self.user?.refreshToken = token?.refreshToken
            
                self.requestKakaoUserInfo()
            }
        }
        else {
            let k = 0
        }
    }
    func requestKakaoUserInfo() {
        UserApi.shared.me { (user: User?, error: Error?) in
            if let error = error {
                self.completion?(nil, error)
                return
            }
            
            guard let user = user else {
                self.completion?(nil, error)
                return
            }
            
            if let email = user.kakaoAccount?.email {
                self.user?.email = email
            }
            self.user?.profileImageUrl = nil
            if let profileImageUrl:URL = user.kakaoAccount?.profile?.profileImageUrl {
                self.user?.profileImageUrl = profileImageUrl.absoluteString
            }
            if let nickname = user.kakaoAccount?.profile?.nickname {
                self.user?.nickname = nickname
                self.user?.name = nickname
            }
            if let birthyear = user.kakaoAccount?.birthyear {
                self.user?.birthday = birthyear
            }
            if let birthday = user.kakaoAccount?.birthday {
                self.user?.birthday = birthday
            }
            if let gender = user.kakaoAccount?.gender?.rawValue {
                self.user?.gender = gender
            }
            
            self.completion?(self.user, nil)
        }
    }
    
    func logout(completion: @escaping (_ error: Error?) -> Void) {
        UserApi.shared.logout { (error: Error?) in
            if let error = error {
                print("kakao logout error: \(error)")
                completion(error)
            }
            else {
                print("kakao logout success.")
                completion(nil)
            }
        }
    }
}
