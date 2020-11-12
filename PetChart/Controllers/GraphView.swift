//
//  GraphView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class GraphView: UIView {
    @IBOutlet weak var lbCurTitle: UILabel!
    @IBOutlet weak var firstSeperator: UIView!
    
    @IBOutlet var arrGraphView: [UIView]!
    @IBOutlet var arrGraphHeight: [NSLayoutConstraint]!
    
    var type:GraphType = .day
    var data:Array<[String:Any]>?
    
    var colorGraph: UIColor = UIColor.black
    var colorBackground: UIColor = UIColor.white
    var colorSeperator: UIColor = RGB(217, 217, 217)
    var colorTextColor: UIColor = RGB(136, 136, 136)
    
    var maxGraphHeight:CGFloat = 0.0
    
    var stDate: Date?
    var edDate: Date?
    
    var maxValue:Int = 0
    let df:CDateFormatter = CDateFormatter.init()
    var calendar = Calendar.init(identifier: .gregorian)
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func configurationGraph(type:GraphType, colorGraph: UIColor?) {
        calendar.locale = Locale.init(identifier: "ko_KR")
        
        self.backgroundColor = colorBackground
        arrGraphView = arrGraphView.sorted(by: { (vw1, vw2) -> Bool in
            return vw1.tag < vw2.tag
        })
        
        self.type = type
        if let colorGraph = colorGraph {
            self.colorGraph = colorGraph
        }
        
        let curDate = Date()
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale.init(identifier: "ko_KR")
        lbCurTitle.text = String(format: "%02d월", curDate.getMonth())
        
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
            lbCurTitle.text = String(format: "%02d월", curDate.getMonth())
            
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
                    lbDay.text = String(format: "%2d주", i+1)
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
            let strYear = String(format: "%04d", curDate.getYear()).suffix(2)
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
        for item in data! {
            if let value1 = item["value1"] as? Int, value1 > maxValue {
                maxValue = value1
            }
        }
    }
    
    func reloadData() {
        guard let data = data else {
            return
        }
        
        if let item = data.last {
            if let key = item["key"] as? String {
                
                df.dateFormat = "yyyy-MM-dd"
                if let lastData = df.date(from: key) {
                    df.dateFormat = "MM"
                    let strMonth = df.string(from: lastData)
                    lbCurTitle.text = "\(strMonth)월"
                }
            }
        }
        
        self.setMaxValue()
    
        for i in 0..<arrGraphView.count {
            let graphView = arrGraphView[i]
            if i < data.count {
            
                graphView.isHidden = false
                let item = data[i]
                let value1 = (item["value1"] as? Int) ?? 0
                
                if let lbValue = graphView.viewWithTag(500) as? UILabel {
                    lbValue.text = "\(value1)"
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
                    if let key = item["key"] as? String {
                        print("marking day: \(key)")
                        df.dateFormat = "yyyy-MM-dd"
                        if let date = df.date(from: key) {
                            let componets = calendar.dateComponents([.month, .weekdayOrdinal,  .weekOfMonth], from: date)
                            if let lbDay = graphView.viewWithTag(400) as? UILabel {
                                lbDay.text = "\(componets.month ?? 1)/\(componets.weekdayOrdinal ?? 1)주"
                                lbDay.textColor = colorTextColor
                            }
                        }
                    }
                }
                else if type == .month {
                    if let key = item["key"] as? String {
                        print("marking day: \(key)")
                        df.dateFormat = "yyyy-MM-dd"
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
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        } completion: { (finish) in
        }

    }
    func getGraphHeight(value:Int) -> CGFloat {
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
