//
//  HomeGraphCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit

class HomeGraphCell: UIView {
    
    @IBOutlet weak var btnBg: UIButton!
    @IBOutlet weak var ivMark: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var vwToday: UIView!
    @IBOutlet weak var lbTodayTitle: UILabel!
    @IBOutlet weak var lbTodayValue: UILabel!
    @IBOutlet weak var sliderToday: UISlider!
    
    @IBOutlet weak var vwYesterday: UIView!
    @IBOutlet weak var lbYesterdayTitle: UILabel!
    @IBOutlet weak var lbYesterdayValue: UILabel!
    @IBOutlet weak var sliderYesterday: UISlider!
    
    var didSelectedClosure:((_ selData:Any?, _ index:Int) ->())? { didSet {} }
    var data:Dictionary <String, Any>? = nil
    var type: PetHealth? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = RGB(238, 238, 238).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func configurationData(_ data: Dictionary<String, Any>?, type:PetHealth) {
        self.data = data
        self.type = type
        
        lbTitle.text = type.koreanValue()
        
        let imgDotYesterday = UIImage(named: "oval_black")
        let colorYesterday = RGB(95, 101, 117)
        
        if let imgMark = type.markImage() {
            ivMark.image = imgMark
        } else {
            ivMark.image = nil
        }
        
        if let color = type.colorType() {
            lbTodayTitle.textColor = color
            sliderToday.minimumTrackTintColor = color
        } else {
            lbTodayTitle.textColor = colorYesterday
            sliderToday.minimumTrackTintColor = colorYesterday
        }
        
        if let imgDot = type.sliderImage() {
            sliderToday.setThumbImage(imgDot, for: .normal)
        }
        else {
            sliderToday.setThumbImage(nil, for: .normal)
        }
        
        lbYesterdayTitle.textColor = colorYesterday
        sliderYesterday.setThumbImage(imgDotYesterday, for: .normal)
        sliderYesterday.minimumTrackTintColor = colorYesterday
        
        guard let data = self.data else {
            return
        }
        
        
        var maxValue:Float = 1.0
        var today:Float = 0.0
        var yesterday:Float = 0.0
        
        if let value = data["maxValue"] as? NSNumber {
            maxValue = value.floatValue
        }
        if let value = data["today"] as? NSNumber {
            today = value.floatValue
        }
        if let value = data["yesterday"] as? NSNumber {
            yesterday = value.floatValue
        }
        print("graph type:\(type.koreanValue() ?? "")")
        print("maxValue:\(maxValue)")
        print("today:\(today)")
        print("yesterday:\(yesterday)\n\n\n")
        
        sliderToday.maximumValue = Float(maxValue)
        sliderYesterday.maximumValue = Float(maxValue)
        sliderToday.setValue(Float(today), animated: true)
        sliderYesterday.setValue(Float(yesterday), animated: true)
        
        let result = NSMutableString.init()
        
        if type == .drink {
            result.setString("오늘 \(type.koreanValue()!)량이 어제")
            
            lbTodayValue.text = "\(Utility.numberToString(num: today))ml"
            lbYesterdayValue.text = "\(Utility.numberToString(num: yesterday))ml"
        }
        else if type == .eat {
            let gramp = "g"
            result.setString("오늘 \(type.koreanValue()!)량이 어제")
            lbTodayValue.text = "\(Utility.numberToString(num: today))\(gramp)"
            lbYesterdayValue.text = "\(Utility.numberToString(num: yesterday))\(gramp)"
        }
        else if type == .weight {
            let gramp = "kg"
            result.setString("오늘 \(type.koreanValue()!)량이 어제")
            lbTodayValue.text = "\(Utility.numberToString(num: today))\(gramp)"
            lbYesterdayValue.text = "\((Utility.numberToString(num: yesterday)))\(gramp)"
        }
        else if type == .feces {
            let gramp = "회"
            
            result.setString("오늘 \(type.koreanValue()!) 횟수가 어제")
            lbTodayValue.text = "\((Utility.numberToString(num: today)))\(gramp)"
            lbYesterdayValue.text = "\((Utility.numberToString(num: yesterday)))\(gramp)"
        }
        else if type == .walk {
            let gramp = "분"
            result.setString("오늘 \(type.koreanValue()!)시간이 어제")
            lbTodayValue.text = "\((Utility.numberToString(num: today)))\(gramp)"
            lbYesterdayValue.text = "\((Utility.numberToString(num: yesterday)))\(gramp)"
        }
        else if type == .medical {
            result.setString("오늘 \(type.koreanValue()!)가 어제")
            lbTodayValue.text = "\((Utility.numberToString(num: today)))"
            lbYesterdayValue.text = "\((Utility.numberToString(num: yesterday)))"
        }
        
        if yesterday > 0 {
            var valueStr = ""
            let percent:Float = ((today - yesterday)/yesterday) * 100
            if percent > 0 {
                valueStr = "\(Utility.numberToString(num: percent))%"
                result.append("보다 \(valueStr) 늘었어요.")
            }
            else if percent < 0 {
                valueStr = "\((Utility.numberToString(num: abs(percent))))%"
                result.append("보다 \(valueStr) 줄었어요.")
            }
            else {
                result.append("와 같습니다.")
            }
            
            let attr = NSMutableAttributedString.init(string: result as String)
            if valueStr.isEmpty == false {
                attr.addAttribute(.foregroundColor, value: ColorDefault , range:result.range(of: valueStr))
                attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold) , range:result.range(of: valueStr))
            }
        
            lbSubTitle.attributedText = attr
        }
        else {
            result.setString("전일 데이터가 존재하지 않습니다.")
            let attr = NSMutableAttributedString.init(string: result as String)
            lbSubTitle.attributedText = attr
        }
        
    }
    @IBAction func onClickedButtonActions(_ sender: Any) {
        if (sender as? NSObject) == btnBg {
            didSelectedClosure?(data, 0)
        }
    }
}
