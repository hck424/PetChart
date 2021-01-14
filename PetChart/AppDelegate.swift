//
//  AppDelegate.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
import CoreData
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import KakaoSDKAuth
import KakaoSDKCommon
import NaverThirdPartyLogin
import FirebaseMessaging
@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loadingView: UIView? = nil
    var timerIot:Timer? = nil;
    var iotStatusRequestCount = 0
    class func instance() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func mainTabbarCtrl() -> MainTabBarController? {
        return self.window?.rootViewController as? MainTabBarController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        
        KakaoSDKCommon.initSDK(appKey: KAKAO_NATIVE_APP_KEY)
        if #available(iOS 13, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        SharedData.instance.pToken = SharedData.getToken()
        
        //네이버
        let naverThirdPartyLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
          // 네이버 앱으로 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
          naverThirdPartyLoginInstance?.isNaverAppOauthEnable = true
          // SafariViewContoller에서 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
          naverThirdPartyLoginInstance?.isInAppOauthEnable = true
          // 인증 화면을 iPhone의 세로 모드에서만 사용하려면 다음 코드를 추가합니다.
          naverThirdPartyLoginInstance?.setOnlyPortraitSupportInIphone(true)
          // 애플리케이션 이름
          naverThirdPartyLoginInstance?.appName = (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? ""
          // 콜백을 받을 URL Scheme
        naverThirdPartyLoginInstance?.serviceUrlScheme = NAVER_URL_SCHEME
          // 애플리케이션에서 사용하는 클라이언트 아이디
        
        naverThirdPartyLoginInstance?.consumerKey = NAVER_CONSUMER_KEY
          // 애플리케이션에서 사용하는 클라이언트 시크릿
        naverThirdPartyLoginInstance?.consumerSecret = NAVER_CONSUMER_SECRET
        
        let dfs = UserDefaults.standard;
        let showTutorial = dfs.object(forKey: IsShowTutorial)
        if showTutorial == nil {
            self.callTutorialVc()
            dfs.setValue("Y", forKey: IsShowTutorial)
            
            //차트 디폴트 세팅
            let arrHealth:[PetHealth] = [.drink, .eat, .weight, .feces, .walk]
            for type in arrHealth {
                let keyHomeGraph = type.udfHomeGraphKey()
                dfs.setValue(type.rawValue, forKey: keyHomeGraph)
                let keyTotalChart = type.udfTotalChartKey()
                dfs.setValue(type.rawValue, forKey: keyTotalChart)
            }
            dfs.setValue(PetHealth.drink.rawValue, forKey: kSmartChartDrink)
            dfs.setValue(PetHealth.eat.rawValue, forKey: kSmartChartEat)
            dfs.synchronize()
        }
        else {
            if let _ = SharedData.objectForKey(key: kUserId), let _ = SharedData.objectForKey(key: kPToken) {
                self.requestUpdateToken()
                self.callMainVc()
            }
            else {
                self.callLoginVc()
            }
        }
        
        if (SharedData.objectForKey(key: kAPPLECATION_UUID) as? String) == nil {
//            let newUUID = Utility.getUUID()
            if let newUUID = UIDevice.current.identifierForVendor?.uuidString {
                SharedData.setObjectForKey(key: kAPPLECATION_UUID, value: newUUID)
                dfs.synchronize()
            }
        }
        
        self.requestAppVersionInfo()
        
        print("=== uuid : \(SharedData.objectForKey(key: kAPPLECATION_UUID)!)")
        SharedData.instance.userIdx = SharedData.objectForKey(key: kUserIdx) as? Int ?? -1
        self.registApnsPushKey()
        return true
    }
    func requestAppVersionInfo() {
        guard let uuid = SharedData.objectForKey(key: kAPPLECATION_UUID) else {
            return
        }
        let param = ["uuid":uuid, "taget":"iOS"];
        ApiManager.shared.requestAppVersionInfo(param: param) { (response) in
            guard let response = response as? [String:Any], let data = response["data"] as? [String:Any] else {
                return
            }
            if let c_ver = data["c_ver"] {
                
            }
            if let m_ver = data["m_ver"] {
                
            }
            if let taget = data["taget"] {
                
            }
        } failure: { (error) in
            print(error)
        }
    }
    func requestUpdateToken() {
        if let token = SharedData.getToken(),
           let userId = SharedData.getUserId(),
           let loginType = SharedData.getLoginType() {
            
            if token.isEmpty == false && userId.isEmpty == false && loginType.isEmpty == false {
                
                let param = ["id": userId, "login_type": loginType]
                ApiManager.shared.requestUpdateAuthToken(param: param) { (response) in
                    print(String(describing: response))
                    if let response = response as? [String:Any], let data = response["data"] as? [String: Any] {
                        if let token = data["token"] as? String {
                            SharedData.setObjectForKey(key: kPToken, value: token)
                            SharedData.instance.pToken = token
                            print("==== new token: \(token)")
                            print("==== userId: \(SharedData.objectForKey(key: kUserId) ?? "")")
                            print("==== logintype: \(SharedData.objectForKey(key: kLoginType) ?? "")")
                        
                            ApiManager.shared.requestAppConfig(success: nil, failure: nil)
                        }
                        else {
                            SharedData.removeObjectForKey(key: kPToken)
                            SharedData.instance.pToken = nil
                            print("error: token 갱신오류")
                        }
                    }
                    else {
                        SharedData.removeObjectForKey(key: kPToken)
                        SharedData.instance.pToken = nil
                        print("error: token 갱신오류")
                    }
                } failure: { (error) in
                    SharedData.removeObjectForKey(key: kPToken)
                    SharedData.instance.pToken = nil
                    print(String(describing: error))
                }
            }
        }
    }
    
    func callLoginVc() {
        let vc = LoginViewController.init()
        let navi = BaseNavigationController.init(rootViewController: vc)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
    func callTutorialVc() {
        let vc: TutorialViewController = TutorialViewController.init()
        window?.rootViewController = vc;
        window?.makeKeyAndVisible()
    }
    func callMainVc() {
        let mainTabVc = MainTabBarController.init()
        window?.rootViewController = mainTabVc
        window?.makeKeyAndVisible()
    }
    func stopIotTimer() {
        self.iotStatusRequestCount = 0
        if let timerIot = timerIot {
            timerIot.invalidate()
            timerIot.fire()
        }
    }
    func startTimerIot() {
        self.stopIotTimer()
        self.timerIot = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(checkIotState), userInfo: nil, repeats: true)
    }
    
    @objc func checkIotState() {
        //백그라운드
        DispatchQueue.global(qos: .userInitiated).async {
            ApiManager.shared.requestIotStatus { (response) in
                print("iot status check background : \(response ?? "")")
                if var result = response as? [String:Any] {
                    self.iotStatusRequestCount += 1
                    if self.iotStatusRequestCount > 4 {
                        result["timeout"] = true    //4*7=28초 이후면 타임아웃  //10초 너무 긴것 같다.
                        self.stopIotTimer()
                        NotificationCenter.default.post(name: Notification.Name(kNotiNameIotState), object: result)
                    }
                    else {
                        result["timeout"] = false
                        NotificationCenter.default.post(name: Notification.Name(kNotiNameIotState), object: result)
                    }
                }
            } failure: { (error) in
                print("error check status background error: \(error ?? "")")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        if let scheme = url.scheme {
            if scheme.contains("com.app.petchart") {
                let result = NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
                if result == CANCELBYUSER {
                    print("result: \(String(describing: result))")
                }
                return true
            }
        }
        return true
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView == nil {
                self.loadingView = UIView(frame: UIScreen.main.bounds)
            }
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 1234321
            self.loadingView?.startAnimation(raduis: 25.0)
            
            //혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다. 10초후에
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
//                if let loadingView = AppDelegate.instance()?.window?.viewWithTag(1234321) {
//                    loadingView.removeFromSuperview()
//                }
//            }
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView != nil {
                self.loadingView!.stopAnimation()
                self.loadingView?.removeFromSuperview()
            }
        })
    }
    
    func openUrl(_ url:String, completion: ((_ success:Bool) -> Void)?) {
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let requestUrl = URL.init(string: encodedUrl) else {
            return
        }
        UIApplication.shared.open(requestUrl, options: [:]) { (success) in
            completion?(success)
        }
    }
    
    func registApnsPushKey() {
        Messaging.messaging().delegate = self
        self.registerForRemoteNoti()
    }
    func registerForRemoteNoti() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted: Bool, error:Error?) in
            if granted == true {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if deviceToken.count == 0 {
            return
        }
        print("==== apns token:\(deviceToken.hexString)")
        //파이어베이스에 푸쉬토큰 등록
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 앱이 백그라운드에있는 동안 알림 메시지를 받으면
    //이 콜백은 사용자가 애플리케이션을 시작하는 알림을 탭할 때까지 실행되지 않습니다.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("=== apn token regist failed")
    }
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PetChart")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
extension AppDelegate: UNUserNotificationCenterDelegate {
    //앱이 켜진상태, Forground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        guard let title = alert["title"] as? String else {
            return
        }
        
        var message:String?
        if let body = alert["body"] as? String {
            message = body
        }
        else if let body = alert["body"] as? [String:Any] {
            
        }
        
        guard let msg = message else {
            return
        }
        
        AlertView.showWithOk(title: title, message: msg) { (index) in
        }
    }
    
    //앱이 백그라운드 들어갔을때 푸쉬온것을 누르면 여기 탄다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        guard let aps = userInfo["aps"] as? [String:Any], let alert = aps["alert"] as? [String:Any] else {
            return
        }
        //푸쉬 데이터를 어느화면으로 보낼지 판단 한고 보내 주는것 처리해야한다.
        //아직 화면 푸쉬 타입에 따른 화면 정리 안됨
        SharedData.setObjectForKey(key: kPushUserData, value: alert)
    }
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("===== error: fcm token key not receive")
            return
        }
        //uniqe한 키이다. 장비 바뀌면 바뀜, 앱지웠다 설치해다 키는 항상 같다 키체인에 저장
        guard let udid = SharedData.objectForKey(key: kAPPLECATION_UUID) else {
            return
        }
        
        print("==== fcm token: \(fcmToken)")
        //앱서버에 fcmkey 올려준다.
        
        let param = ["deviceUID":udid, "p_token":fcmToken]
        print("=== uuid: \(udid), fcmtoken:\(fcmToken)")
        ApiManager.shared.requestUpdateFcmToken(param: param) { (response) in
            if let response = response as? [String:Any], let success = response["success"] as? Bool, success == true {
                print("===== success: fcm token app server upload")
            }
            else {
                print("===== fail: fcm token app server upload")
            }
        } failure: { (error) in
            print("===== fail: fcm token app server upload")
        }
    }
}
