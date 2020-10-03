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
    
    var didSelectedClouser:((_ selData:Any?, _ index:Int) ->())? { didSet {} }
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
    }
    @IBAction func onClickedButtonActions(_ sender: Any) {
        if (sender as? NSObject) == btnBg {
            didSelectedClouser?(data, 0)
        }
    }
}
