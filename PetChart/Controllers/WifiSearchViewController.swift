//
//  WifiSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//
// IOT서비스 시작 : conent -> station -> setting -> servicestart
import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension


class WifiSearchViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tvWifiName: UITextField!
    @IBOutlet weak var btnWifiName: UIButton!
    @IBOutlet weak var tfWifiPassword: UITextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgview: UIView!
    @IBOutlet weak var lbHintPassword: UILabel!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var btnEye: UIButton!
    
    var sessionKey:String?
    var isChangeWifi = false
    
    var selWifi: WifiInfo?
    private let SSID = ""
    var arrWifiList:[WifiInfo] = [WifiInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, "Wifi 검색", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        cornerBgview.layer.cornerRadius = 20
        cornerBgview.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        tfWifiPassword.delegate = self
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_:)))
        self.view.addGestureRecognizer(tap)
        
        showPopUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_:)), name: Notification.Name(kNotiNameIotState), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotiNameIotState), object: nil)
        
        guard let selWifi = selWifi else {
            return
        }
        
        if isChangeWifi == false && selWifi.password?.isEmpty == false {
            self.connetedWifi(wifi: selWifi) { (success, error) in
                
            }
        }
    }
    
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    func showPopUp() {
        if self.arrWifiList.isEmpty {
            AlertView.showWithOk(title: nil, message: "와이파이 검색결과가 없습니다.\n설정에서 와이파이를 켰는지 확인해주세요.", completion: nil)
        }
        else {
            let vc = PopupListViewController.init(type: .wifi, title: "와이파이를 선택해 주세요.", data: self.arrWifiList, keys: nil) { (vcs, selData:Any?, index) in
                
                if let selData = selData as? WifiInfo {
                    self.selWifi = selData
                    self.tvWifiName.text = self.selWifi?.ssid
                }

                vcs.dismiss(animated: true, completion: nil)
            }
            vc.edgeTitle = UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20)
            vc.widthRate = 0.6
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            
            for wifiInfo in self.arrWifiList {
                print("wifi interface :\(String(describing: wifiInfo.interface)), ssid: \(String(describing: wifiInfo.ssid)), bssid:\(String(describing: wifiInfo.bssid))")
            }
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnWifiName {
            arrWifiList = self.getWifiInfo()
            showPopUp()
        }
        else if sender == btnEye {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                tfWifiPassword.isSecureTextEntry = false
            }
            else {
                tfWifiPassword.isSecureTextEntry = true
            }
        }
        else if sender == btnOk {
            self.view.endEditing(true)
            
            guard let ssid = tvWifiName.text, ssid.isEmpty == false else {
                self.view.makeToast("Wifi를 선택해주세요.")
                return
            }
            guard let password = tfWifiPassword.text, password.isEmpty == false else {
                self.view.makeToast("Wifi 비밀번호를 입력해주세요.")
                return
            }
            //연결 해제 할때도 wifi 비밀번호를 받지 않기 위해 저장해놓는다.
            SharedData.setObjectForKey(key: kMyHomeWifiPassword, value: password)
            self.selWifi?.password = password
            
            self.requestIotStation()
        }
    }
    
    func requestIotStation() {
        guard let ssid = self.selWifi?.ssid, let sessionKey = sessionKey, let passwordKey = selWifi?.password else {
            return
        }
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = df.string(from: Date())
        
        let param:[String:Any] = ["sessionKey": sessionKey, "ssid": ssid, "passwordKey":passwordKey, "timestamp":timestamp];
        AppDelegate.instance()?.startIndicator()
        AppDelegate.instance()?.startTimerIot()
        ApiManager.shared.requestIotStation(param: param) { (response) in
            print("== iot station: \(String(describing: response))")
            if let response = response as?[String:Any], let _ = response["result"] as? Bool {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    self.requestIotSetting()
                }
            }
        } failure: { (error) in
            self.view.makeToast("Iot request stattion error")
        }
    }
    func requestIotSetting() {
        guard let sessionKey = sessionKey, let loginType = SharedData.getLoginType(), let idx = SharedData.objectForKey(key: kUserIdx), let userId = SharedData.getUserId() else {
            return
        }
        
        let uid = "\(loginType)_\(userId)"
        let url = SERVER_PREFIX
        let param:[String:Any] = ["idx":idx, "sessionKey":sessionKey, "uid":uid, "url":url]
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotSetting(param: param) { (response) in
            print("===iot setting success:\(String(describing: response))")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                self.requestServiceStart()
            }
        } failure: { (error) in
            self.view.makeToast("Iot Setting Request Error")
        }
    }
    
    func requestServiceStart() {
        guard let sessionKey = sessionKey else {
            return
        }
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotServiceStart(sessionKey: sessionKey) { (response) in
            print("iot service start response:\(response ?? "")")
        } failure: { (error) in
            self.view.makeToast("Iot Sevice start request error")
        }
    }
    func getWifiInfo() -> Array<WifiInfo> {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        let wifiInfo:[WifiInfo] = interfaceNames.compactMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            guard let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String else {
                return nil
            }
            return WifiInfo(interface: name, ssid: ssid, bssid: bssid, password: nil, model: nil)
        }
        return wifiInfo
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name == Notification.Name(kNotiNameIotState) {
            guard let response = notification.object as? [String:Any] else {
                return
            }
            if let server_status = response["server-status"] as? String, server_status == "registered" {
                AppDelegate.instance()?.stopIndicator()
                AppDelegate.instance()?.stopIotTimer()
                AlertView.showWithOk(title: "IOT 연결", message: "기기 연결이 완료 되었습니다.") { (index) in
                    self.connetedWifi(wifi: self.selWifi!) { (success, error) in
                        if (success) {
                            self.isChangeWifi = true
                            self.navigationController?.popToRootViewController(animated: false)
                            UserDefaults.standard.setValue(PetHealth.drink.rawValue, forKey: kSmartChartDrink)
                            UserDefaults.standard.setValue(PetHealth.eat.rawValue, forKey: kSmartChartEat)
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            }
            if let timeout = response["timeout"] as? Bool, timeout == true {
                AppDelegate.instance()?.stopIndicator()
                AppDelegate.instance()?.stopIotTimer()
                AlertView.showWithOk(title: "타임 아웃", message: "연결시간 초과되었습니다.\n다시시도해주세요", completion: nil)
            }
            
        }
        else if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification{
          
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
     
            if notification.name == UIResponder.keyboardWillShowNotification {
                let safeBottom = AppDelegate.instance()?.window?.safeAreaInsets.bottom ?? 0
                bottomContainer.constant = heightKeyboard - safeBottom
                UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                    self.view.layoutIfNeeded()
                })
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                bottomContainer.constant = 0
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
