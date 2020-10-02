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
import SwiftKeychainWrapper

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var uuid: String = ""
    
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
            dfs.synchronize()
        }
        else {
            self.callMainVc()
        }
        
        self.uuid = Utility.getUUID()
        print("===== uuid: \(uuid)")
        
        
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        if let scheme = url.scheme {
            if scheme.contains("naver") {
                let result = NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
                if result == CANCELBYUSER {
                    print("result: \(String(describing: result))")
                }
                return true
            }
        }
        return true
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PetChart")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
