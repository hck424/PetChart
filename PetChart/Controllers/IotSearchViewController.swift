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
    var sessionKey:String?
    
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
        
        if self.wifiList.isEmpty == false {
            //iot 장비의 wifi로 체인지 후 다 연결되면 현재 와이파이로 자동으로 변경된다.
            //그러나 도중에 iot 장비로 붙은 진행하지 않고 나갈때는 집 wifi 로 변경 해주어야 홈데이터를 불러올수있다.
            if var wifi = wifiList.first, let passowrd = SharedData.objectForKey(key: kMyHomeWifiPassword) as? String {
                wifi.password = passowrd
                self.connetedWifi(wifi: wifi) { (sate, error) in
    
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
            AppDelegate.instance()?.stopIndicator()
            if let response = response as? [String:Any] {
                if let sessionKey = response["session-key"] as? String, sessionKey.isEmpty == false {
                    self.sessionKey = sessionKey
                    self.checkIotState()
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

    func checkIotState() {
        ApiManager.shared.requestIotStatus { (response) in
            print("=== iot status: \(String(describing: response))")
            if let response = response as? [String:Any], let ap_status = response["ap-status"] as? String, ap_status == "connected" {
                let vc = WifiSearchViewController.init()
                vc.arrWifiList = self.wifiList
                vc.sessionKey = self.sessionKey
                self.navigationController?.pushViewController(vc, animated: false)
            }
            else {
                AlertView.showWithOk(title: "연결 상태", message: "Iot 장비에 연결 실패하였습니다.", completion: nil)
            }
        } failure: { (error) in
            print("=== iot status error: \(String(describing: error))")
        }
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
                AlertView.showWithOk(title: wifi.ssid, message: "장비 Wifi 연결되었습니다.") { (index) in
                    self.requestIotConnetion()
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
