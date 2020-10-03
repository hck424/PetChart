//
//  ChartCellView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartCellView: UIView {
    
    @IBOutlet weak var btnMark: UIButton!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet var arrDayView: [UIView]!
    @IBOutlet var arrGraphHeight: [NSLayoutConstraint]!
    
    var data:Dictionary<String, Any>? = nil
    var type:PetHealth = .drink
    var category:String? = nil
    
    var didClickedClosure:((_ selDate: Any?, _ category: String?, _ type:PetHealth, _ index:Int) -> ())? {
        didSet {
        }
    }
    
    func configurationData(category: String?, type: PetHealth, data:Dictionary<String, Any>?) {
        self.data = data
        self.type = type
        self.category = category
        
        let ivMark = btnMark.viewWithTag(1)
        if let ivMark = ivMark as? UIImageView {
            if let imgMark = type.markImage() {
                ivMark.image = imgMark
            }
            else {
                ivMark.image = nil
            }
        }
        
        var color = UIColor.black
        if let ccolor = type.colorType() {
            color = ccolor
        }
        
        let lbMark = btnMark.viewWithTag(2)
        if let lbMark = lbMark as? UILabel {
            lbMark.text = type.koreanValue()
            lbMark.textColor = color
        }
        
        for vw in arrDayView {
            let graph = vw.viewWithTag(100)
            graph?.backgroundColor = color
        }
        
        let df = CDateFormatter()
        df.dateFormat = "yyyyMMdd"
        let date = df.date(from: "20201001")! as Date
        let curDate = Date()
        
        let compareDate = df.date(from: "20200930")! as Date
    
        lbMonth.text = String(format: "%02d월", curDate.getMonth())
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale.init(identifier: "ko_KR")
        let arrWeekDays = calendar.daysWithSameWeekOfYear(as: date)
        
        for i in 0..<arrWeekDays.count {
            let day = arrWeekDays[i]
            
            var findHeight:NSLayoutConstraint? = nil
            for height in arrGraphHeight {
                let identifier = (height.identifier ?? "0") as String
                if Int(identifier) == (i+1) {
                    findHeight = height
                    break
                }
            }
            
            if day <= compareDate {
                if let findHeight = findHeight {
                    findHeight.constant = CGFloat(Int(arc4random_uniform(100)))
                }
            }
            else {
                if let findHeight = findHeight {
                    findHeight.constant = 0.0
                }
            }
            
            let vw = arrDayView[i]
            if let lbDay = vw.viewWithTag(400) as? UILabel {
               lbDay.text = String(format: "%02d", day.getDay())
            }
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMark {
            didClickedClosure?(data, category, type, 0)
        }
    }
}
