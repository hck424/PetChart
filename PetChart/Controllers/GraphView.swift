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
    var data:Array<Any>?
    
    var colorGraph: UIColor = UIColor.black
    var colorBackground: UIColor = UIColor.white
    var colorSeperator: UIColor = RGB(217, 217, 217)
    var colorTextColor: UIColor = RGB(136, 136, 136)
    
    var maxGraphHeight:CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func configurationGraph(type:GraphType, colorGraph: UIColor?, data:Array<Any>?) {
        
        arrGraphView = arrGraphView.sorted(by: { (vw1, vw2) -> Bool in
            return vw1.tag < vw2.tag
        })
        
        self.type = type
        if let colorGraph = colorGraph {
            self.colorGraph = colorGraph
        }
        self.data = data
        
        let curDate = Date()
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale.init(identifier: "ko_KR")
        let arrDays = calendar.daysWithSameWeekOfYear(as: curDate)
        
        lbCurTitle.textColor = colorTextColor
        firstSeperator.backgroundColor = colorSeperator
        maxGraphHeight = self.bounds.height - 20 - 1
        
        //그래프 그리기
        if type == .day {
            lbCurTitle.text = String(format: "%02d월", curDate.getMonth())
            
            for i in 0..<arrGraphView.count {
                let graphView = arrGraphView[i]
                graphView.backgroundColor = UIColor.clear
                if i < arrDays.count {
                    graphView.isHidden = false
                    let graph = graphView.viewWithTag(100)
                    graph?.backgroundColor = colorGraph
                    
                    let serperV = graphView.viewWithTag(200)
                    serperV?.backgroundColor = colorSeperator
                    
                    let serperH = graphView.viewWithTag(300)
                    serperH?.backgroundColor = colorSeperator
                    
                    let day = arrDays[i]
                    if let lbDay = graphView.viewWithTag(400) as? UILabel {
                        lbDay.text = String(format: "%02d", day.getDay())
                        lbDay.textColor = colorTextColor
                    }
                    
                    for const in arrGraphHeight {
                        let identifier = Int(const.identifier ?? "0")
                        if identifier == i+1 {
                            let height = getGraphHeight(index: i)
                            const.constant = height
                            break
                        }
                    }
                }
                else {
                    graphView.isHidden = true
                }
            }
        }
        else if type == .week {
            lbCurTitle.text = String(format: "%02d월", curDate.getMonth())
            
            for i in 0..<arrGraphView.count {
                let graphView = arrGraphView[i]
                graphView.backgroundColor = UIColor.clear
                if i < 4 {
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
                            let height = getGraphHeight(index: i)
                            const.constant = height
                            break
                        }
                    }
                }
                else {
                    graphView.isHidden = true
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
                        let height = getGraphHeight(index: i)
                        const.constant = height
                        break
                    }
                }
            }
        }
    }
    
    func getGraphHeight(index: Int) ->CGFloat {
        return CGFloat(arc4random_uniform(UInt32(maxGraphHeight)))
    }
    
    class func initWithFromNib() ->GraphView {
        return Bundle.main.loadNibNamed("GraphView", owner: nil, options: nil)?.first as! GraphView
    }
}
