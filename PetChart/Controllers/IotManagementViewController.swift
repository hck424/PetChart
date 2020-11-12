//
//  IotManagementViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

///IOT중지 : connect -> servicestop -> reset -> disconnect

import UIKit
import CoreLocation

class IotManagementViewController: BaseViewController {
    @IBOutlet weak var lbPetNameTitle: UILabel!
    @IBOutlet weak var lbIotName: UILabel!
    @IBOutlet weak var lbIotModel: UILabel!
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var btnDisConnet: CButton!
    @IBOutlet weak var btnIotRemove: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var cornerContainer: UIView!
    
    var locationManager: CLLocationManager?
    var device:[String:Any]?
    var wifiList:Array<WifiInfo> = Array<WifiInfo>()
    var sessionKey:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기 설정", nil)
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        cornerContainer.layer.cornerRadius = 20
        cornerContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        self.decorationUI()
        
        self.getAllWifiList { (list) in
            guard let list = list else {
                return
            }
            print(list)
        }
        //현재 연결된 집 와이파이를 요청해서 저장한다. 왜냐하면 끝나고 나서 wifi 돌려나야 되기 때문에
        //사용가능한 wifi ssid 리스트를 못가져와서, 현재 연결된 wifi 만 가져올수 있다. apple 이슈
        let status = CLLocationManager.authorizationStatus()
        AppDelegate.instance()?.startIndicator()
        if status == .authorizedWhenInUse {
            self.scanCurrentWifi()
        } else {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard var wifi = self.wifiList.first, let _ = wifi.ssid, let password = SharedData.objectForKey(key: kMyHomeWifiPassword) as? String else {
            return
        }
        self.getAllWifiList { (list) in
            guard let list = list else {
                return
            }
            print(list)
        }
        wifi.password = password
        self.connetedWifi(wifi: wifi) { (finish, error) in
            if error != nil {
                self.view.makeToast("와이파이 변경 오류가 발생했습니다.\n 설정에서 집 와이파이로 변경해주십시오.")
            }
        }
    }
    
    func scanCurrentWifi() {
        //현재 접속된 wifi 저장하고 있는다
        self.wifiList = self.fetchWifi()
        AppDelegate.instance()?.stopIndicator()
        if wifiList.isEmpty {
            AlertView.showWithOk(title: nil, message: "와이파이 검색결과가 없습니다.\n설정에서 와이파이를 켰는지 확인해주세요.", completion: nil)
        }
    }
    
    func decorationUI() {
        guard let device = device else {
            lbPetNameTitle.text = ""
            lbIotName.text = ""
            lbIotModel.text = ""
            return
        }
        
        var result = ""
        if let petName = SharedData.objectForKey(key: kMainShowPetName) {
            result.append("\(petName)의 식사시간")
        }
        lbPetNameTitle.text = result
        
        lbIotName.text = "장비명:"
        if let name = device["name"] as? String {
            result.append("\(name)")
            lbIotName.text = "장비명: \(name)"
        }
        
        lbIotModel.text = "모델명:"
        if let model = device["model"] as? String {
            lbIotModel.text = "모델명: \(model)"
        }
        
        if let state = device["state"] as? String, state == "run" {
            btnDisConnet.setTitle("연결 되었습니다.", for: .normal)
            btnDisConnet.setTitleColor(RGB(51, 150, 254), for: .normal)
            btnDisConnet.isSelected = true
        }
        else {
            btnDisConnet.setTitle("연결이 되지 않았습니다.", for: .normal)
            btnDisConnet.setTitleColor(RGB(136, 136, 136), for: .normal)
            btnDisConnet.isSelected = false
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnModify {
            
            var msg = ""
            if let name = device?["name"] as? String {
                msg = "\(name)을 수정 하시겠습니까?"
            }
            else {
                msg = "Iot 장비명 수정하시겠습니까?"
            }
            let alert = UIAlertController.init(title: "장비명 수정", message: msg, preferredStyle: .alert)
            alert.addTextField { (textField) in
            }
            alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "확인", style: .default, handler: { (action) in
                if let newName = alert.textFields?.first?.text, newName.isEmpty == false {
                    self.requestModifyDeviceName(newName)
                }
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if sender == btnDisConnet {
            // 장비와 통신하기 위해 wifi change 해야한다.
            let wifi = WifiInfo.init(interface:"PETCHART" , ssid: "PETCHART", bssid: nil, password:"petchart123!", model: "")
            self.connetedWifi(wifi: wifi) { (success, error) in
                if error != nil {
                    if let msg = error?.localizedDescription {
                        AlertView.showWithOk(title: nil, message: msg, completion: nil)
                    }
                }
                else {
                    AlertView.showWithOk(title: wifi.ssid, message: "장비 Wifi 연결되었습니다.") { (index) in
                        self.requestIotConnetion()
                    }
                }
            }
        }
        else if sender == btnIotRemove {
            self.removeAppServerDeleteIotDevice()
        }
    }
    
    func removeAppServerDeleteIotDevice() {
        guard let device = device, let id = device["id"] else {
            return
        }
        
        ApiManager.shared.requestDeleteDevice(pid: "\(id)") { (response) in
            if let response = response as?[String:Any],
               let success = response["success"] as? Bool, success == true {
                self.view.makeToast("장치 삭제가 완료되었습니다.")
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            
        }
    }
    func requestIotConnetion() {
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotConnet { (response) in
            print("=== iot connetct success:\(String(describing: response))")
            AppDelegate.instance()?.stopIndicator()
            if let response = response as? [String:Any] {
                if let sessionKey = response["session-key"] as? String, sessionKey.isEmpty == false {
                    self.sessionKey = sessionKey
                    //1초후에
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        self.requestIotServiceStop()
                    }
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            AppDelegate.instance()?.stopIndicator()
            self.showErrorAlertView(error)
        }
    }
    func requestIotServiceStop() {
        guard let sessionKey = self.sessionKey else {
            return
        }
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotServiceStop(sessionKey: sessionKey) { (response) in
            //1초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                AppDelegate.instance()?.stopIndicator()
                self.requestIotReset()
            }
        } failure: { (error) in
            AppDelegate.instance()?.stopIndicator()
            self.showErrorAlertView(error)
        }
    }
    func requestIotReset() {
        guard let sessionKey = self.sessionKey else {
            return
        }
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotReset(sessionKey: sessionKey) { (response) in
            //1초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                AppDelegate.instance()?.stopIndicator()
                self.requestIotDisconnect()
            }
        
        } failure: { (error) in
            AppDelegate.instance()?.stopIndicator()
            self.showErrorAlertView(error)
        }
    }
    
    func requestIotDisconnect() {
        guard let sessionKey = self.sessionKey else {
            return
        }
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotDisConnet(sessionKey: sessionKey) { (response) in
            //1초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                AppDelegate.instance()?.stopIndicator()
                self.checkIotState()
            }
        } failure: { (error) in
            AppDelegate.instance()?.stopIndicator()
            self.showErrorAlertView(error)
        }
    }
    
    func checkIotState() {
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotStatus { (response) in
            AppDelegate.instance()?.stopIndicator()
            if let response = response as? [String:Any], let ap_status = response["ap-status"] as? String, ap_status == "disconnected" {
              
                self.btnDisConnet.setTitle("연결이 되지 않았습니다.", for: .normal)
                self.btnDisConnet.setTitleColor(RGB(136, 136, 136), for: .normal)
                self.btnDisConnet.isSelected = false
                
                AlertView.showWithOk(title: "연결 상태", message: "Iot 장비에 해제되었습니다.") { (index) in
                    guard var wifi = self.wifiList.first, let password = SharedData.objectForKey(key: kMyHomeWifiPassword) as? String else {
                        return
                    }
                    wifi.password = password
                    self.connetedWifi(wifi: wifi) { (finish, error) in
                        if error != nil {
                            self.view.makeToast("와이파이 변경 오류가 발생했습니다.\n 설정에서 집 와이파이로 변경해주십시오.")
                        }
                        else {
                            self.removeAppServerDeleteIotDevice()
                        }
                    }
                }
            }
        } failure: { (error) in
            AppDelegate.instance()?.stopIndicator()
            print("=== iot status error: \(String(describing: error))")
        }
    }
    func requestModifyDeviceName(_ name: String) {
        guard let device = device, let mac = device["mac"], let devices_id = device["id"] else {
            return
        }
        
        let param = ["devices_id": devices_id, "mac": mac, "name": name]
        
        ApiManager.shared.requetModifyDeviceName(param: param) { (response) in
            if let response = response as? [String:Any], let success = response["success"] as? Bool, success == true {
                
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }

    }
}

extension IotManagementViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.scanCurrentWifi()
        }
    }
}
