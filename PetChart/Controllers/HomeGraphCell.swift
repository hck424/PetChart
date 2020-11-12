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
        
        let maxValue:Int = (data["maxValue"] as? Int) ?? 1
        let today:Int = (data["today"] as? Int) ?? 0
        let yesterday:Int  = (data["yesterday"] as? Int) ?? 0
        
        sliderToday.maximumValue = Float(maxValue)
        sliderYesterday.maximumValue = Float(maxValue)
        
        sliderToday.setValue(Float(today), animated: true)
        sliderYesterday.setValue(Float(yesterday), animated: true)
        
//        yesterday:100 = today:%
//        % = (today*100)/yesterday
        let todayPercent:Float = Float(today * 100)/Float(yesterday)
        var attr:NSMutableAttributedString?
        let result:NSMutableString = NSMutableString.init()
        if type == .drink {
            result.setString("오늘 \(type.koreanValue()!)량이 어제")
            lbTodayValue.text = "\(today)ml"
            lbYesterdayValue.text = "\(yesterday)ml"
        }
        else if type == .eat || type == .weight || type == .feces {
            var gramp = "g"
            if type == .weight {
                gramp = "kg"
            }
            result.setString("오늘 \(type.koreanValue()!)량이 어제")
            lbTodayValue.text = "\(today)\(gramp)"
            lbYesterdayValue.text = "\(yesterday)\(gramp)"
        }
        else if type == .walk {
            result.setString("오늘 \(type.koreanValue()!)시간이 어제")
            lbTodayValue.text = "\(today)"
            lbYesterdayValue.text = "\(yesterday)"
        }
        else if type == .medical {
            result.setString("오늘 \(type.koreanValue()!)가 어제")
            lbTodayValue.text = "\(today)"
            lbYesterdayValue.text = "\(yesterday)"
        }
        
//        어제 : 100% = 오늘 : %
//        % = (오늘*100)/어제
//        if % > 100 {
//            let value = Int(% - 100)
//            // value 만큼 늘었어요
//        }
//        else if % < 100 {
//            let value = 100 - %
//            // value 만큼 즐었어요
//        }
//        else {
//            같아요
//        }
        if todayPercent > 100 {
            let value = Int(todayPercent - 100)
            let valueStr = "\(value)%"
            result.append("보다 \(valueStr) 늘었어요.")
            
            attr = NSMutableAttributedString.init(string: result as String)
            attr?.addAttribute(.foregroundColor, value: ColorDefault , range:result.range(of: valueStr))
            attr?.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold) , range:result.range(of: valueStr))
            
        }
        else if todayPercent < 100 {
            let value = Int(100 - todayPercent)
            let valueStr = "\(value)%"
            result.append("보다 \(valueStr) 줄었어요.")
            
            attr = NSMutableAttributedString.init(string: result as String)
            attr?.addAttribute(.foregroundColor, value: ColorDefault , range:result.range(of: valueStr))
            attr?.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold) , range:result.range(of: valueStr))
        }
        else {
            result.append("와 같습니다.")
            attr = NSMutableAttributedString.init(string: result as String)
        }
     
        lbSubTitle.attributedText = attr!
        
        
    }
    @IBAction func onClickedButtonActions(_ sender: Any) {
        if (sender as? NSObject) == btnBg {
            didSelectedClosure?(data, 0)
        }
    }
}
