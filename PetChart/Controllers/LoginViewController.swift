//
//  LoginViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import AuthenticationServices
import CryptoSwift

@IBDesignable
class LoginViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var bgCorner: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnLogin: CButton!
    @IBOutlet weak var tfEmail: CTextField!
    @IBOutlet weak var tfPassword: CTextField!
    @IBOutlet weak var btnFindPassword: UIButton!
    @IBOutlet weak var btnJoinEmail: UIButton!
    @IBOutlet weak var btnKakao: CButton!
    @IBOutlet weak var btnFacebook: CButton!
    @IBOutlet weak var btnNaver: CButton!
    @IBOutlet weak var btnApple: CButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var bottomScrollView: NSLayoutConstraint!
    @IBOutlet weak var lbHitUserId: UILabel!
    @IBOutlet weak var lbHitPassword: UILabel!
    
    var user: UserInfo? = nil
    var currentNonce: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        bgCorner.layer.cornerRadius = 20
        bgCorner.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        
        let str1: String = "안녕하세요.\n스마트한 우리아이 건강관리의 시작\n "
        let img = UIImage(named: "logo_red")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let attchment = NSTextAttachment.init(image: img!)
        
        attchment.bounds = CGRect.init(x: 0, y: -1, width: img!.size.width, height: img!.size.height)
        let attr = NSMutableAttributedString.init(attachment: attchment)
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorDefault, range:NSRange(location: 0, length: attr.length))
        
        let resultAttr = NSMutableAttributedString.init(string: str1)
        resultAttr.append(attr)
        resultAttr.append(NSAttributedString.init(string: " 입니다"))
        
        lbTitle.attributedText = resultAttr
        
        tfEmail.text = SharedData.getUserId() ?? ""
        btnCheck.isSelected = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @IBAction func tapGestureHanlder(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            self.view.endEditing(true)
        }
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnClose {
            self.navigationController?.popViewController(animated: false)
        }
        else if sender == btnLogin {
            lbHitUserId.isHidden = true
            lbHitPassword.isHidden = true
            var isOk = true
            if tfEmail.text?.count == 0 {
                lbHitUserId.isHidden = false
                isOk = false
            }
            if tfPassword.text?.count == 0 {
                lbHitPassword.isHidden = false
                isOk = false
            }
            if isOk == false {
                return
            }
            
            
            var param:[String:Any] = [:]
            param["id"] = tfEmail.text!
            param["password"] = tfPassword.text!
            param["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID)!
            param["login_type"] = SharedData.getLoginType() ?? "none"
            param["p_token"] = SharedData.getToken() ?? "123....."
            
            ApiManager.shared.requestUserSignIn(param: param) { (response) in
               
                if let response = response as? [String:Any],
                   let success = response["success"] as? Bool,
                   let data = response["data"] as? [String: Any] {
                    
                    if success == false {
                        self.showErrorAlertView(response)
                        return
                    }
                    
                    
                    if let token = data["token"] as? String {
                        if self.btnCheck.isSelected {
                            //로그인 유지 userdefault 쓴다.
                            SharedData.setObjectForKey(key: kPToken, value: token)
                            SharedData.instance.pToken = token
                        }
                        else {
                            //메모리에 유지
                            SharedData.instance.pToken = token
                        }
                    }
                    if let idx = data["idx"] as? Int {
                        SharedData.setObjectForKey(key: kUserIdx, value: idx)
                    }
                    if let password = self.tfPassword.text {
                        SharedData.setObjectForKey(key: kUserPassword, value: password)
                    }
                    
                    if let join_type = data["join_type"] as? String,
                       let user_id = data["user_id"] as? String {
                        
                        let realUserId = user_id.deletingPrefix("\(join_type)_")
                        
                        SharedData.setObjectForKey(key: kLoginType, value: join_type)
                        SharedData.setObjectForKey(key: kUserId, value: realUserId)
                    }
                    
                    self.navigationController?.popViewController(animated: false)
                }
                
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
        }
        else if sender == btnCheck {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnKakao {
            KakaoController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                print("kakao: \(String(describing: user?.accessToken!))")
            }
        }
        else if sender == btnNaver {
            NaverController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                print("naver: \(String(describing: user?.accessToken!))")
            }
        }
        else if sender == btnFacebook {
            FbController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                print("facebook: \(String(describing: user?.accessToken))")
            }
        }
        else if sender == btnApple {
            let request = createAppIdRequest()
            let autorizationController = ASAuthorizationController(authorizationRequests: [request])
            autorizationController.delegate = self
            autorizationController.presentationContextProvider = self
            autorizationController.performRequests()
            
        }
        else if sender == btnFindPassword {
            let vc = FindPassWordViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnJoinEmail {
            let vc = MrStep1ViewController.init(nibName: "MrStep1ViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createAppIdRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        
        currentNonce = nonce
        return request
    }
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomScrollView.constant = heightKeyboard
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
            
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomScrollView.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = inputData.sha256()
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let none = currentNonce else {
                fatalError("Invalid state: A login callbak was recevied, but no loin request was sent")
                return
            }
            guard let appIdToken = appleIdCredential.identityToken else {
                print("Unable to fetch idntify token")
                return
            }
            
            guard let idToken = String(data: appIdToken, encoding: .utf8) else {
                print("Unable to serialize token string from data:\(appIdToken.description)")
                return
            }
            self.user = UserInfo.init(JSON: ["access_token": idToken])
            
            print ("user appid token : \(idToken)")
            
            // Initialize a Firebase credential.
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idToken,
                                                      rawNonce: none)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                else {
                    self.user?.userId = authResult?.user.uid
                    self.user?.email = authResult?.user.email
                    self.user?.name = authResult?.user.displayName
                }
            }
        }
        
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (self.view.window)!
    }
}
