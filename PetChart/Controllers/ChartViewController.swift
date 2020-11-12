//
//  ChartViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class ChartViewController: BaseViewController {

    @IBOutlet weak var svSmart: UIStackView!
    @IBOutlet weak var svSmartContainer: UIStackView!
    @IBOutlet weak var vwSmartBg: UIView!
    @IBOutlet weak var btnSettingSmart: UIButton!
    @IBOutlet weak var btnSmartDevice: CButton!
    
    @IBOutlet weak var svTotal: UIStackView!
    @IBOutlet weak var vwTotalBg: UIView!
    @IBOutlet weak var svTotalContainer: UIStackView!
    @IBOutlet weak var btnSettingTotal: UIButton!
    
    let arrHealth:[PetHealth] = [.drink, .eat, .weight, .feces, .walk]
    var isConnectedIot = false
    
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
                self.configuraitonUi()
            }
            else if type == .expire {
                self.showAlertWithLogin(isExpire: true)
                self.svSmart.isHidden = true
                self.svTotal.isHidden = true
            }
            else {
                self.showAlertWithLogin(isExpire: false)
                self.svSmart.isHidden = true
                self.svTotal.isHidden = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configuraitonUi() {
        
        let dfs = UserDefaults.standard
        
        var arrSmart: [PetHealth] = [PetHealth]()
        if dfs.object(forKey: kSmartChartDrink) != nil {
            arrSmart.append(.drink)
        }
        if dfs.object(forKey: kSmartChartEat) != nil {
            arrSmart.append(.eat)
        }
        
        var arrTotal:[PetHealth] = [PetHealth]()
        for type in arrHealth {
            let key = type.udfTotalChartKey()
            if dfs.object(forKey: key) != nil {
                arrTotal.append(type)
            }
        }
    
        if isConnectedIot && arrSmart.isEmpty == false {
            //스마트 차트가 설정된거 있으면
            for type in arrSmart {
                for i in 0..<arrTotal.count {
                    let totalType = arrTotal[i]
                    if type == totalType {
                        arrTotal.remove(at: i)
                    }
                }
            }
        }
        
        
        if arrSmart.isEmpty == true {
            svSmart.isHidden = true
        } else {
            svSmart.isHidden = false
        }

        if arrTotal.isEmpty == true {
            //만일 다 OFF 이면 다 켠다
            arrTotal.append(contentsOf: arrHealth)
        }
        
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
        
        for subView in svTotalContainer.subviews {
            subView.removeFromSuperview()
        }
        if arrTotal.isEmpty == false {
            svTotal.isHidden = false
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
            vc.data = arrHealth
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}
