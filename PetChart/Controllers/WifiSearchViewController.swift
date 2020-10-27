//
//  WifiSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/14.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension


class WifiSearchViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tvWifiName: CTextView!
    @IBOutlet weak var btnWifiName: UIButton!
    @IBOutlet weak var tfWifiPassword: UITextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerBgview: UIView!
    @IBOutlet weak var lbHintPassword: UILabel!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var btnEye: UIButton!
    
    var iotSessionKey:String?
    
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
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
                    self.tvWifiName.placeholderLabel?.isHidden = true
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
            var isOk = true
            if selWifi?.ssid?.isEmpty == true {
                isOk = false
            }
            if let password = tfWifiPassword.text, password.isEmpty == true {
                isOk = false
            }
            
            if isOk == false {
                AlertView.showWithOk(title: nil, message: "와이파이를 설정해주세요", completion: nil)
                return
            }
            
            let ssid = self.selWifi?.bssid
            let sessionKey = iotSessionKey!
            let passwordKey = tfWifiPassword.text!
            self.selWifi?.password = passwordKey
    
            let df = DateFormatter.init()
            df.locale = Locale.init(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
            df.timeZone = TimeZone.init(secondsFromGMT: 60*60*9)
            let timestamp = df.string(from: Date())
            
            let param:[String:Any] = ["sessionKey": sessionKey, "ssid": ssid!, "passwordKey":passwordKey, "timestamp":timestamp];
            ApiManager.shared.requestIotStation(param: param) { (response) in
                print("== iot station: \(String(describing: response))")
                if let response = response as?[String:Any], let result = response["result"] as? Bool {
                    if result == true {
                        self.requestServiceStart()
                    }
                }
            } failure: { (error) in
                print("== iot station error: \(String(describing: error))")
            }
        }
    }
   
    func requestServiceStart() {
        let sessionKey = iotSessionKey!
        ApiManager.shared.requestIotServiceStart(sessionKey: sessionKey) { (response) in
            if let response = response as?[String:Any], let result = response["result"] as? Bool {
                if result == true {
                    AlertView.showWithOk(title: nil, message: "기기 연결이 완료 되었습니다.") { (index) in
                        
                        self.connetedWifi(wifi: self.selWifi!) { (success, error) in
                            if (success) {
                                self.navigationController?.popToRootViewController(animated: false)
                            }
                        }
                    }
                }
                else {
                    ApiManager.shared.requestIotStatus { (response) in
                        print("=== iot status:\(String(describing: response))")
                
                    } failure: { (error) in
                        print("=== iot status error:\(String(describing: error))")
                    }

                    self.showErrorAlertView(response)
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func scaneWifi() {
        let manager = NEHotspotConfigurationManager.shared
        
        let ssid = "PETCHART-D6F9F1"
        let pwd = "petchart123!"
        manager.getConfiguredSSIDs { (list) in
            print("==== list:\(list)")
        }
        
        let hotspot = NEHotspotConfiguration(ssid: ssid, passphrase: pwd, isWEP: false)
        hotspot.joinOnce = true
        manager.apply(hotspot) { (error) in
            if let error = error {
                print("== error: \(error)")
            }
            else {
                print("success")
            }
        }
        manager.getConfiguredSSIDs { (list) in
            print("==== list:\(list)")
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
