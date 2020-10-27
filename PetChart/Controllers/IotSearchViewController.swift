//
//  IotSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit
import CoreLocation



class IotSearchViewController: BaseViewController {
    
    @IBOutlet weak var lbIotSearchStatus: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var locationManager: CLLocationManager?
    var wifiList:Array<WifiInfo> = Array<WifiInfo>()
    
    var arrTblData:Array<WifiInfo> = Array<WifiInfo>()
    var iotConectedInfo:[String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "기기 등록", nil)
        
        tblView.layer.cornerRadius = 20
        tblView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        self.makeTableData()
        self.getAllWifiList { (list) in
            if let list = list {
                for wifissid in list {
                    print("=== wifi list:\(wifissid)")
                }
            }
        }
        //현재 연결된 집 와이파이를 요청해서 저장한다.
        //사용가능한 wifi ssid 리스트를 못가져와서
        let status = CLLocationManager.authorizationStatus()
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
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func makeTableData() {
        let wifi = WifiInfo.init(interface:"PETCHART" , ssid: "PETCHART-D6F9F1", bssid: nil, password:"petchart123!", model: "D6F9F1")
        arrTblData.append(wifi)
        self.tblView.reloadData()
    }
    
    func scanCurrentWifi() {
        self.wifiList = self.fetchWifi()
        if wifiList.isEmpty {
            AlertView.showWithOk(title: nil, message: "와이파이 검색결과가 없습니다.\n설정에서 와이파이를 켰는지 확인해주세요.", completion: nil)
        }
    }
    
    func requestIotStation() {
        ApiManager.shared.requestIotConnet { (response) in
            print("=== iot connetct success:\(String(describing: response))")
            if let response = response as? [String:Any] {
                if let sessionKey = response["session-key"] as? String, sessionKey.isEmpty == false {
                    self.iotConectedInfo = response
                    SharedData.setObjectForKey(key: sessionKey, value: kIOT_SESSION_KEY)
                    self.requestIotSetting()
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func requestIotSetting() {
        
        let idx = SharedData.objectForKey(key: kUserIdx)!
        let sessionKey = self.iotConectedInfo?["session-key"] as! String
        let uid = SharedData.getUserId()!
        let url = SERVER_PREFIX
        let param:[String:Any] = ["idx":idx, "sessionKey":sessionKey, "uid":uid, "url":url]
        
        ApiManager.shared.requestIotSetting(param: param) { (response) in
            print("===iot setting success:\(String(describing: response))")
            if let response = response as? [String :Any], let result = response["result"] as? Bool {
                if result {
                    self.gotoWifiSearch()
                }
                else {
                    self.gotoWifiSearch()
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
            self.gotoWifiSearch()
        }
    }

    func gotoWifiSearch() {
        ApiManager.shared.requestIotStatus { (response) in
            print("=== iot status: \(String(describing: response))")
        } failure: { (error) in
            print("=== iot status error: \(String(describing: error))")
        }

        let vc = WifiSearchViewController.init()
        vc.arrWifiList = wifiList
        vc.iotSessionKey = iotConectedInfo?["session-key"] as? String
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
            if error != nil {
                if let msg = error?.localizedDescription {
                    AlertView.showWithOk(title: nil, message: msg, completion: nil)
                }
            }
            else {
                AlertView.showWithOk(title: wifi.ssid, message: "연결되었습니다.") { (index) in
                    self.requestIotStation()
                }
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
