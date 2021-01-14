//
//  IotSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit
import CoreLocation

class IotSearchViewController: BaseViewController {
    
    @IBOutlet weak var ivDeviceSearch: UIImageView!
    @IBOutlet weak var lbIotSearchStatus: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var locationManager: CLLocationManager?
    var wifiList:Array<WifiInfo> = Array<WifiInfo>()
    
    var arrTblData:Array<WifiInfo> = Array<WifiInfo>()
    var sessionKey:String?
    var isChangeWifi = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기 등록", nil)
        
        tblView.layer.cornerRadius = 20
        tblView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        //와이파이 초기화 용도 실지 와이파이 리스트 못 가져옴, fetchWifi 현재 연결된 wifi 가져온다.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: Notification.Name(kNotiNameIotState), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.instance()?.stopIndicator()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotiNameIotState), object: nil)
        guard var wifi = self.wifiList.first, let passowrd = SharedData.objectForKey(key: kMyHomeWifiPassword) as? String else {
            return
        }
        
        if isChangeWifi == false {
            wifi.password = passowrd
            self.connetedWifi(wifi: wifi) { (success, error) in
                
            }
        }
    }
    func makeTableData() {
        //장비 ssid, password 고정 리스트에
        let wifi = WifiInfo.init(interface:"PETCHART" , ssid: "PETCHART", bssid: nil, password:"petchart123!", model: "")
        arrTblData.append(wifi)
        self.tblView.reloadData()
    }
    
    func scanCurrentWifi() {
        self.wifiList = self.fetchWifi()
        AppDelegate.instance()?.stopIndicator()
        if wifiList.isEmpty {
            AlertView.showWithOk(title: nil, message: "와이파이 검색결과가 없습니다.\n설정에서 와이파이를 켰는지 확인해주세요.", completion: nil)
        }
        else {
            self.makeTableData()
            self.tblView.reloadData()
        }
    }
    
    func requestIotConnetion() {
        AppDelegate.instance()?.startIndicator()
        ApiManager.shared.requestIotConnet { (response) in
            print("=== iot connetct success:\(String(describing: response))")
            if let response = response as? [String:Any] {
                if let sessionKey = response["session-key"] as? String, sessionKey.isEmpty == false {
                    self.sessionKey = sessionKey
                    //state check background 돌림
                    AppDelegate.instance()?.startTimerIot()
                }
            }
        } failure: { (error) in
            
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name == Notification.Name(kNotiNameIotState) {
            guard let response = notification.object as? [String:Any] else {
                return
            }
            
            if let ap_status = response["ap-status"] as? String, ap_status == "connected" {
                AppDelegate.instance()?.stopIndicator()
                AppDelegate.instance()?.stopIotTimer()
                self.gotoWifiSearchVC()
                return
            }
            if let timeout = response["timeout"] as? Bool, timeout == true {
                AppDelegate.instance()?.stopIndicator()
                AppDelegate.instance()?.stopIotTimer()
                AlertView.showWithOk(title: "타임 아웃", message: "연결시간 초과되었습니다.\n다시시도해주세요", completion: nil)
            }
        }
    }
    
    func gotoWifiSearchVC() {
        let vc = WifiSearchViewController.init()
        vc.arrWifiList = self.wifiList
        vc.sessionKey = self.sessionKey
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension IotSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTblData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "IotDeviceCell") as? IotDeviceCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("IotDeviceCell", owner: self, options: nil)?.first as? IotDeviceCell
        }
        
        let wifi = arrTblData[indexPath.row]
        cell?.lbTitle.text = wifi.interface
        cell?.lbSubtitle.text = wifi.model
        
        return cell!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let wifi = arrTblData[indexPath.row]
        //iot Device wifi change 한다.
        self.connetedWifi(wifi: wifi) { (success, error) in
            if success {
                self.isChangeWifi = true
                AlertView.showWithOk(title: wifi.ssid, message: "장비 Wifi 연결되었습니다.") { (index) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        self.requestIotConnetion()
                    }
                }
            }
            else {
                self.view.makeToast("장비 와이파이 연결 실패하였습니다.")
            }
        }
    }
    
}
extension IotSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.scanCurrentWifi()
        }
    }
}
