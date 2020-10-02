//
//  FbController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/28.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

typealias fbClouser = (UserInfo?, Error?) -> Void
class FbController: NSObject {
    
    func login(viewcontorller: UIViewController, competion:fbClouser?) {
        let loginManager = LoginManager()
        let readPermission:[Permission] = [.publicProfile, .email]
   
        loginManager.logIn(permissions: readPermission, viewController: viewcontorller) { (result: LoginResult) in
            
            switch result {
            case .success(granted: _, declined: _, token: _):
                self.signInFirebase()
            case .cancelled:
                print("facebook login cancel")
                competion?(nil, nil);
            case .failed(let err):
                print(err)
                competion?(nil, err);
            }
        }
    }
    func signInFirebase() {
//        if let token = AccessToken.current, !token.isExpired {
//
//        }
        guard let token = AccessToken.current?.tokenString else {
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signIn(with: credential) { (user: AuthDataResult?, error: Error?) in
            if let error = error {
                print(error)
            }
            else {
                self.fetchFacebookMe()
            }
        }
    }
    func fetchFacebookMe() {
        
    }
}
