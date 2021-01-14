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
        btnCheck.isSelected = true
        
        if let loginType = SharedData.getLoginType(), loginType == "none" {
            tfEmail.text = SharedData.getUserId() ?? ""
            if let passwrod = SharedData.objectForKey(key: kUserPassword) as? String {
                tfPassword.text = passwrod
            }
        }
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
    func reqeustSignUp(param:[String:Any]) {
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
                    SharedData.instance.userIdx = idx
                }
                if let password = self.tfPassword.text {
                    SharedData.setObjectForKey(key: kUserPassword, value: password)
                }
                if let nickname = data["nickname"] as? String {
                    SharedData.setObjectForKey(key:kUserNickName, value: nickname)
                }
                if let join_type = data["join_type"] as? String,
                   let user_id = data["user_id"] as? String {
                    
                    let realUserId = user_id.deletingPrefix("\(join_type)_")
                    
                    SharedData.setObjectForKey(key: kLoginType, value: join_type)
                    SharedData.setObjectForKey(key: kUserId, value: realUserId)
                }
                
                AppDelegate.instance()?.callMainVc()
            }
            
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    @IBAction func tapGestureHanlder(_ sender: UITapGestureRecognizer) {
        if sender.view == self.view {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func textFieldEdtingChanged(_ sender: UITextField) {
        SharedData.setObjectForKey(key: kLoginType, value: "none")
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnClose {
            self.navigationController?.popViewController(animated: false)
        }
        else if sender == btnLogin {
            
            guard let email = tfEmail.text, email.isEmpty == false, email.validateEmail() == true else {
                self.showToast("이메일 형식이 아닙니다.")
                return
            }

            guard let pasword = tfPassword.text, pasword.isEmpty == false, pasword.validatePassword() == true else {
                self.showToast("비밀번호(숫자,영문,특수문자 8자이상)를 입력해주세요.")
                return
            }

            var param:[String:Any] = [:]
            param["id"] = email
            param["password"] = pasword
            param["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID)!
            param["login_type"] = SharedData.getLoginType() ?? "none"
            param["p_token"] = Messaging.messaging().fcmToken
            param["dtype"] = "ios"
            self.reqeustSignUp(param: param)

        }
        else if sender == btnCheck {
            sender.isSelected = !sender.isSelected
        }
        else if sender == btnKakao {
            if let loginType = SharedData.getLoginType(), let id = SharedData.getUserId(), loginType == "kakao" {
                var param:[String:Any] = [:]
                param["id"] = id
                param["password"] = id
                param["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID)!
                param["login_type"] = SharedData.getLoginType() ?? "none"
                param["p_token"] = SharedData.instance.pToken ?? "123....."
                self.reqeustSignUp(param: param)
            }
            else {
                KakaoController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                    guard let user = user, let userId = user.userId else {
                        return
                    }
                    self.requestValiedSocialLogin(user: user)
                }
            }
        }
        else if sender == btnNaver {
            
            if let loginType = SharedData.getLoginType(), let id = SharedData.getUserId(), loginType == "naver" {
                var param:[String:Any] = [:]
                param["id"] = id
                param["password"] = id
                param["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID)!
                param["login_type"] = SharedData.getLoginType() ?? "none"
                param["p_token"] = SharedData.instance.pToken ?? "123....."
                self.reqeustSignUp(param: param)
            }
            else {
                NaverController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                    
                    guard let user = user, let _ = user.userId else {
                        return
                    }
                    print("naver userId: \(user.userId ?? "")")
                    self.requestValiedSocialLogin(user: user)
                }
            }
        }
        else if sender == btnFacebook {
            if let loginType = SharedData.getLoginType(), let id = SharedData.getUserId(), loginType == "facebook" {
                var param:[String:Any] = [:]
                param["id"] = id
                param["password"] = id
                param["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID)!
                param["login_type"] = SharedData.getLoginType() ?? "none"
                param["p_token"] = SharedData.instance.pToken ?? "123....."
                self.reqeustSignUp(param: param)
            }
            else {
//                FbController().logout { (error) in
//                }
                FbController().login(viewcontorller: self) { (user: UserInfo?, error: Error?) in
                    guard let user = user, let _ = user.userId else {
                        return
                    }
                    print("facebook userId:  \(user.userId ?? "")")
                    self.requestValiedSocialLogin(user: user)
                }
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
            let vc = MrTermsViewController.init(nibName: "MrTermsViewController", bundle: nil)
            vc.user = UserInfo(JSON: ["join_type": "none"])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func requestValiedSocialLogin(user:UserInfo) {
        guard  let joinType = user.joinType, let userId = user.userId else {
            return
        }
        let param = ["join_type": joinType, "uid": userId]
        
        ApiManager.shared.requestValidSocialLogin(param: param) { (response) in
            if let response = response as? [String: Any], let success = response["success"] as? Bool, let msg = response["msg"] as? String {
                if success && msg == "가입이 되어있습니다." {
                    var loginParam = ["id":userId, "login_type":joinType, "password":userId]
                    loginParam["deviceUID"] = SharedData.objectForKey(key: kAPPLECATION_UUID) as! String
                    loginParam["p_token"] = SharedData.instance.pToken ?? "123....."
                    self.reqeustSignUp(param: loginParam)
                }
                else {
                    let vc = MrTermsViewController.init()
                    vc.user = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
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
                    self.user?.joinType = "apple"
                    self.requestValiedSocialLogin(user: self.user!)
                }
            }
        }
        
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }
        else if textField == tfPassword {
            self.view.endEditing(true)
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorDefault
            textField.setNeedsDisplay()
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorBorder
            textField.setNeedsDisplay()
        }
        return true
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (self.view.window)!
    }
}
