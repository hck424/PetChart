//
//  GraphView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class GraphView: UIView {
    
    @IBOutlet weak var seperatorAverage: UIView!
    @IBOutlet weak var lbAverage: UILabel!
    @IBOutlet weak var heightAverageSeperator: NSLayoutConstraint!

    @IBOutlet weak var lbCurTitle: UILabel!
    @IBOutlet weak var firstSeperator: UIView!
    
    @IBOutlet var arrGraphView: [UIView]!
    @IBOutlet var arrGraphHeight: [NSLayoutConstraint]!
    var healthType:PetHealth = .drink
    var type:GraphType = .day
    var data:Array<[String:Any]>?
    
    var colorGraph: UIColor = UIColor.black
    var colorBackground: UIColor = UIColor.white
    var colorSeperator: UIColor = RGB(217, 217, 217)
    var colorTextColor: UIColor = RGB(136, 136, 136)
    
    var maxGraphHeight:CGFloat = 0.0
    var showAverage = false
    var stDate: Date?
    var edDate: Date = Date()
    var average: Float = 0.0
    
    var maxValue:Float = 1.0
    let df:CDateFormatter = CDateFormatter.init()
    var calendar = Calendar.init(identifier: .gregorian)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func configurationGraph(type:GraphType, colorGraph: UIColor?) {
        lbAverage.isHidden = true
        seperatorAverage.isHidden = true
      
        calendar.locale = Locale.init(identifier: "ko_KR")
        self.backgroundColor = colorBackground
        arrGraphView = arrGraphView.sorted(by: { (vw1, vw2) -> Bool in
            return vw1.tag < vw2.tag
        })
        
        self.type = type
        if let colorGraph = colorGraph {
            self.colorGraph = colorGraph
        }
        

        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale.init(identifier: "ko_KR")
        lbCurTitle.text = String(format: "%0d월", edDate.getMonth())
        
        lbCurTitle.textColor = colorTextColor
        firstSeperator.backgroundColor = colorSeperator
        //boud hegit 에서 bottom, boarder, top value label height 뺀것이 최종 max height
        maxGraphHeight = self.bounds.height - 20 - 1 - 15
        
        //그래프 그리기
        if type == .day {
            for i in 0..<arrGraphView.count {
                let graphView = arrGraphView[i]
                graphView.backgroundColor = UIColor.clear
                
                graphView.isHidden = false
                let graph = graphView.viewWithTag(100)
                graph?.backgroundColor = colorGraph
                
                let serperV = graphView.viewWithTag(200)
                serperV?.backgroundColor = colorSeperator
                
                let serperH = graphView.viewWithTag(300)
                serperH?.backgroundColor = colorSeperator
                
                if let lbDay = graphView.viewWithTag(400) as? UILabel {
                    lbDay.text = String(format: "%02d", i+1)
                    lbDay.textColor = colorTextColor
                }
                
                for const in arrGraphHeight {
                    let identifier = Int(const.identifier ?? "0")
                    if identifier == i+1 {
                        let height = getDefaultGraphHeight(index: i)
                        const.constant = height
                        break
                    }
                }
            }
        }
        else if type == .week {
            lbCurTitle.text = String(format: "%2d월", edDate.getMonth())
            
            for i in 0..<arrGraphView.count {
                let graphView = arrGraphView[i]
                graphView.backgroundColor = UIColor.clear
                
                graphView.isHidden = false
                let graph = graphView.viewWithTag(100)
                graph?.backgroundColor = colorGraph
                
                let serperV = graphView.viewWithTag(200)
                serperV?.backgroundColor = colorSeperator
                
                let serperH = graphView.viewWithTag(300)
                serperH?.backgroundColor = colorSeperator
                
                if let lbDay = graphView.viewWithTag(400) as? UILabel {
                    lbDay.text = String(format: "%d주", i+1)
                    lbDay.textColor = colorTextColor
                }
                
                for const in arrGraphHeight {
                    let identifier = Int(const.identifier ?? "0")
                    if identifier == i+1 {
                        let height = getDefaultGraphHeight(index: i)
                        const.constant = height
                        break
                    }
                }
            }
        }
        else if type == .month {
            let strYear = String(format: "%04d", edDate.getYear()).suffix(2)
            lbCurTitle.text = String(format: "%@년", strYear as CVarArg)
            
            for i in 0..<arrGraphView.count {
                let graphView = arrGraphView[i]
                graphView.isHidden = false
                graphView.backgroundColor = UIColor.clear
                
                graphView.isHidden = false
                let graph = graphView.viewWithTag(100)
                graph?.backgroundColor = colorGraph
                
                let serperV = graphView.viewWithTag(200)
                serperV?.backgroundColor = colorSeperator
                
                let serperH = graphView.viewWithTag(300)
                serperH?.backgroundColor = colorSeperator
                
                if let lbDay = graphView.viewWithTag(400) as? UILabel {
                    lbDay.text = String(format: "%2d월", i+1)
                    lbDay.textColor = colorTextColor
                }
                
                for const in arrGraphHeight {
                    let identifier = Int(const.identifier ?? "0")
                    if identifier == i+1 {
                        let height = getDefaultGraphHeight(index: i)
                        const.constant = height
                        break
                    }
                }
            }
        }
        self.layoutIfNeeded()
    }
    
    func setMaxValue() {
        var sum:Float = 0.0
        guard let data = data else {
            return
        }

        for item in data {
            if let value1 = item["value1"] as? Float {
                if value1 > maxValue {
                    maxValue = value1
                }
                sum += value1
            }
        }
        self.average = sum/Float(data.count)
    }
    
    func reloadData() {
        if maxValue == 0.0 {
            maxValue = 1.0
        }
        
        guard let data = data else {
            return
        }
        
        lbAverage.isHidden = true
        seperatorAverage.isHidden = true
      
        if type == .day {
            lbCurTitle.text = String(format: "%d월/%d일", edDate.getMonth(), edDate.getDay())
        }
        else if type == .week {
            var calendar = Calendar.init(identifier: .gregorian)
            calendar.locale = Locale.init(identifier: "ko_KR")
            let componets = calendar.dateComponents([.month, .weekdayOrdinal, .weekOfYear, .weekOfMonth], from: edDate)
            let week:Int = componets.weekdayOrdinal ?? 1
            lbCurTitle.text = String(format: "%d월/%d주", edDate.getMonth(), week)
        }
        else if type == .month {
            let strYear = String(format: "%04d", edDate.getYear()).suffix(2)
            lbCurTitle.text = String(format: "%@년/%d월", (strYear as CVarArg), edDate.getMonth())
        }
//        self.setMaxValue()
    
        for i in 0..<arrGraphView.count {
            let graphView = arrGraphView[i]
            if i < data.count {
            
                graphView.isHidden = false
                let item = data[i]
                var value1:Float = 0.0
                if let value = item["value1"] as? NSNumber {
                    value1 = value.floatValue
                }
                
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 1
                formatter.roundingMode = .halfEven
                formatter.numberStyle = .decimal
                
                if let lbValue = graphView.viewWithTag(500) as? UILabel {
                    lbValue.text = formatter.string(from: value1 as NSNumber)
                }
                
                if type == .day {
                    if let key = item["key"] as? String {
                        df.dateFormat = "yyyy-MM-dd"
                        if let date = df.date(from: key) {
                            let day = calendar.component(.day, from: date)
                            if let lbDay = graphView.viewWithTag(400) as? UILabel {
                                lbDay.text = String(format: "%02d", day)
                                lbDay.textColor = colorTextColor
                            }
                        }
                    }
                }
                else if type == .week {
                    if let lbDay = graphView.viewWithTag(400) as? UILabel {
                        lbDay.text = "\(i+1)주"
                        lbDay.textColor = colorTextColor
                    }
                }
                else if type == .month {
                    if let key = item["key"] as? String {
                        df.dateFormat = "yyyy-MM"
                        if let date = df.date(from: key) {
                            let componets = calendar.dateComponents([.year, .month], from: date)
                            if let lbDay = graphView.viewWithTag(400) as? UILabel {
                                lbDay.text = "\(componets.month ?? 1)월"
                                lbDay.textColor = colorTextColor
                            }
                        }
                    }
                }
                for const in arrGraphHeight {
                    let identifier = Int(const.identifier ?? "0")
                    if identifier == i+1 {
                        let height = getGraphHeight(value: value1)
                        const.constant = height
                        break
                    }
                }
            }
            else {
                graphView.isHidden = true
            }
        }
        
        if showAverage {
            lbAverage.isHidden = false
            seperatorAverage.isHidden = false
            lbAverage.text = "평균\(healthType.koreanValue()!)량"
            let height = self.getGraphHeight(value: average)
            heightAverageSeperator.constant = height
        }
        
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        } completion: { (finish) in
        }
    }
    func getGraphHeight(value:Float) -> CGFloat {
        //maxvalue:maxheight = valu:? => ? = (maxHeight*value)/maxvalue
        if value == 0 {
            return 0.0
        }
        let height:CGFloat = CGFloat(maxGraphHeight*CGFloat(value))/CGFloat(maxValue)
        return height
    }
    func getDefaultGraphHeight(index: Int) ->CGFloat {
        return 0.0
//        return CGFloat(arc4random_uniform(UInt32(maxGraphHeight)))
    }
    
    class func initWithFromNib() ->GraphView {
        return Bundle.main.loadNibNamed("GraphView", owner: nil, options: nil)?.first as! GraphView
    }
}
