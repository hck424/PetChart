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
    @IBOutlet weak var btnSmartSetting: UIButton!
    @IBOutlet weak var btnSmartDevice: CButton!
    
    @IBOutlet weak var svTotal: UIStackView!
    @IBOutlet weak var vwTotalBg: UIView!
    @IBOutlet weak var svTotalContainer: UIStackView!
    @IBOutlet weak var btnSettingTotal: UIButton!
    
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
        self.configuraitonUi()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configuraitonUi() {
        
        let dfs = UserDefaults.standard
        let arrSmart: NSMutableArray = NSMutableArray()
        if dfs.object(forKey: kSmartChartDrink) != nil {
            arrSmart.add(PetHealth.drink)
        }
        if dfs.object(forKey: kSmartChartEat) != nil {
            arrSmart.add(PetHealth.eat)
        }
        
        let arrTotal: NSMutableArray = NSMutableArray()
        if dfs.object(forKey: kTotalChartDrink) != nil {
            arrTotal.add(PetHealth.drink)
        }
        if dfs.object(forKey: kTotalChartEat) != nil {
            arrTotal.add(PetHealth.eat)
        }
        if dfs.object(forKey: kTotalChartWeight) != nil {
            arrTotal.add(PetHealth.weight)
        }
        if dfs.object(forKey: kTotalChartFeces) != nil {
            arrTotal.add(PetHealth.feces)
        }
        if dfs.object(forKey: kTotalChartWalk) != nil {
            arrTotal.add(PetHealth.walk)
        }
        if dfs.object(forKey: kTotalChartMedical) != nil {
            arrTotal.add(PetHealth.medical)
        }
        
        arrSmart.removeAllObjects()
        arrSmart.addObjects(from: [PetHealth.drink, PetHealth.eat])
        arrTotal.removeAllObjects()
        arrTotal.addObjects(from: [PetHealth.drink, PetHealth.eat, PetHealth.weight, PetHealth.feces, PetHealth.walk, PetHealth.medical])
        
        //스마트 차트에 포함되어 있으면 total 차트에서 뺀다.
        if arrSmart.count > 0 {
            for type in arrSmart {
                if let type: PetHealth = type as? PetHealth {
                    if type.rawValue == PetHealth.drink.rawValue {
                        arrTotal.remove(PetHealth.drink)
                    }
                    else if type.rawValue == PetHealth.eat.rawValue {
                        arrTotal.remove(PetHealth.eat)
                    }
                }
            }
        }
        
//        if arrSmart.count == 0 {
//            svSmart.isHidden = true
//        } else {
//            svSmart.isHidden = false
//        }
//
//        if arrTotal.count == 0 {
//            svTotal.isHidden = true
//        } else {
//            svTotal.isHidden = false
//        }
        
        for subView in svSmartContainer.subviews {
            subView.removeFromSuperview()
        }
        for type in arrSmart {
            if let type: PetHealth = type as? PetHealth {
                let cell = Bundle.main.loadNibNamed("ChartCellView", owner: self, options: nil)?.first as! ChartCellView
                cell.configurationData(category: "스마트 차트", type: type, data: nil)
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = RGB(238, 238, 238).cgColor
                svSmartContainer.addArrangedSubview(cell)
                
                cell.didClickedClosure = ({(selData:Any?, category:String?, type: PetHealth, index:Int) ->() in
                    self.showChartDetailVC(categroy: category, type: type, selData:selData as? Dictionary<String, Any>)
                    print(type.koreanValue()!)
                })
            }
        }
        
        for subView in svTotalContainer.subviews {
            subView.removeFromSuperview()
        }
        
        for type in arrTotal {
            if let type: PetHealth = type as? PetHealth {
                let cell = Bundle.main.loadNibNamed("ChartCellView", owner: self, options: nil)?.first as! ChartCellView
                cell.configurationData(category: "전체 차트", type: type, data: nil)
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
            
        }
    }
}
