//
//  ChartViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class ChartViewController: BaseViewController {

    @IBOutlet weak var svSmartContainer: UIStackView!
    @IBOutlet weak var vwSmartBg: UIView!
    @IBOutlet weak var btnSettingSmart: UIButton!
    @IBOutlet weak var btnSmartDevice: CButton!
    
    @IBOutlet weak var vwTotalBg: UIView!
    @IBOutlet weak var svTotalContainer: UIStackView!
    @IBOutlet weak var btnSettingTotal: UIButton!
    
    var arrDevice:Array<Any>?
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, "차트", nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
        
        vwSmartBg.layer.cornerRadius = 20
        vwSmartBg.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        vwTotalBg.layer.cornerRadius = 20
        vwTotalBg.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSession { (type) in
            if type == .valid {
                self.resuetDeviceList()
            }
            else if type == .expire {
                self.showAlertWithLogin(isExpire: true)
            }
            else {
                self.showAlertWithLogin(isExpire: false)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func resuetDeviceList() {
        ApiManager.shared.requetDeviceList { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as?[String:Any] {

                if let devices = data["devices"] as? Array<[String:Any]> {
                    self.arrDevice = devices
                }
                else {
                    self.arrDevice = nil
                }
            }
            self.configuraitonUi()
        } failure: { (error) in
            self.configuraitonUi()
        }
    }
    
    func configuraitonUi() {
        
        if let arrDevice = arrDevice, arrDevice.isEmpty == false {
            btnSmartDevice.setTitle("기기연결 ON", for: .normal)
        }
        else {
            btnSmartDevice.setTitle("기기연결 OFF", for: .normal)
        }
        
        let dfs = UserDefaults.standard
        
        var arrSmart: [PetHealth] = [PetHealth]()
        
        vwSmartBg.isHidden = true
        vwTotalBg.isHidden = true
        if dfs.object(forKey: kSmartChartDrink) != nil {
            arrSmart.append(.drink)
        }
        if dfs.object(forKey: kSmartChartEat) != nil {
            arrSmart.append(.eat)
        }
        
        if arrSmart.isEmpty == false {
            vwSmartBg.isHidden = false
            
            for subView in svSmartContainer.subviews {
                subView.removeFromSuperview()
            }
            
            for type in arrSmart {
                let cell = Bundle.main.loadNibNamed("ChartCellView", owner: self, options: nil)?.first as! ChartCellView
                cell.configurationData(category: "스마트 차트", type: type)
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = RGB(238, 238, 238).cgColor
                svSmartContainer.addArrangedSubview(cell)
                
                cell.didClickedClosure = ({(selData:Any?, category:String?, type: PetHealth, index:Int) ->() in
                    self.showChartDetailVC(categroy: category, type: type, selData:selData as? Dictionary<String, Any>)
                    print(type.koreanValue()!)
                })
            }
        }
        
        var arrTotal:[PetHealth] = [PetHealth]()
        if dfs.object(forKey: kTotalChartWeight) != nil {
            arrTotal.append(.weight)
        }
        if dfs.object(forKey: kTotalChartFeces) != nil {
            arrTotal.append(.feces)
        }
        if dfs.object(forKey: kTotalChartWalk) != nil {
            arrTotal.append(.walk)
        }
        
        if arrTotal.isEmpty == false {
            vwTotalBg.isHidden = false
            
            for subView in svTotalContainer.subviews {
                subView.removeFromSuperview()
            }
            
            for type in arrTotal {
                let cell = Bundle.main.loadNibNamed("ChartCellView", owner: self, options: nil)?.first as! ChartCellView
                cell.configurationData(category: "전체 차트", type: type)
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = RGB(238, 238, 238).cgColor
                svTotalContainer.addArrangedSubview(cell)
                
                cell.didClickedClosure = ({(selData:Any?, category:String?, type: PetHealth, index:Int) ->() in
                    print(type.koreanValue()!)
                    self.showChartDetailVC(categroy: category, type: type, selData:selData as? Dictionary<String, Any>)
                })
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func showChartDetailVC(categroy:String?, type:PetHealth, selData:Dictionary<String, Any>?) {
        let vc = ChartCategoryViewController.init()
        vc.vcTitle = categroy
        vc.type = type
        vc.data = selData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
            self.checkSession { (session) in
                if session == .valid {
                    self.gotoMyinfoVc()
                }
                else if session == .expire {
                    self.showAlertWithLogin(isExpire: true)
                }
                else {
                    self.showAlertWithLogin(isExpire: false)
                }
            }
        }
        else if sender == btnSettingSmart {
            let vc = PetHealthFavoriteEdtingViewController.init()
            vc.catergory = .chartSmart
            vc.data = [.drink, .eat]
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if sender == btnSettingTotal {
            let vc = PetHealthFavoriteEdtingViewController.init()
            vc.catergory = .chartToal
            vc.data = [.weight, .feces, .walk]
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if sender == btnSmartDevice {
//            let vc = IotListViewController.init()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
