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

class FbController: NSObject {
    var completion:LoginClosure?
    var user:UserInfo?
    
    func login(viewcontorller: UIViewController, completion:LoginClosure?) {
        self.completion = completion;
        let loginManager = LoginManager()
        
        if let token = AccessToken.current, !token.isExpired {
            self.fetchFacebookMe()
        }
        else {
            let readPermission:[Permission] = [.publicProfile, .email]
            loginManager.logIn(permissions: readPermission, viewController: viewcontorller) { (result: LoginResult) in
                switch result {
                case .success(granted: _, declined: _, token: _):
                    self.signInFirebase()
                case .cancelled:
                    print("facebook login cancel")
                    completion?(nil, nil);
                case .failed(let err):
                    print(err)
                    completion?(nil, err);
                }
            }
        }
    }
    func signInFirebase() {
        
        guard let token = AccessToken.current?.tokenString else {
            self.completion?(nil, nil)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (user: AuthDataResult?, error: Error?) in
            if let error = error {
                print(error)
                self.completion?(nil, error)
            }
            else {
                self.fetchFacebookMe()
            }
        }
    }
    func fetchFacebookMe() {
        let connection = GraphRequestConnection()
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, birthday, gender, age_range, picture.type(large)"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: .get)
        
        connection.add(request) { (httpResponse, result, error: Error?) in
            if nil != error {
                print(error!)
                return
            }
            guard let result = result else {
                return
            }
            
            if let dic:Dictionary = result as? Dictionary<String, AnyObject> {
//                self.user = UserInfo()
//                self.user?.accessToken = AccessToken.current?.tokenString
//                self.user?.name = dic["name"] as? String
//                self.user?.email = dic["email"] as? String
//                self.user?.userId = dic["id"] as? String
//                self.user?.birthday = dic["birthday"] as? String
//                self.user?.profileImageUrl = nil
//                if let picture: Dictionary = dic["picture"] as? Dictionary<String, AnyObject> {
//                    if let data: Dictionary =  picture["data"] as? Dictionary<String, AnyObject> {
//                        guard let url = data["url"] else {
//                            return
//                        }
//                        self.user?.profileImageUrl = url as? String
//                    }
//                }
//                if let completion = self.completion {
//                    completion(self.user, nil)
//                }
            }
        }
        connection.start()
    }
    
    func logout(completion: @escaping (_ error: Error?) -> Void) {
        let loginManager = LoginManager()
        loginManager.logOut()
        let auth = Auth.auth()
        do {
            try auth.signOut()
            print("fb logout success")
            completion(nil)
        } catch let error {
            print("fb logout error")
            completion(error)
        }
    }
}
