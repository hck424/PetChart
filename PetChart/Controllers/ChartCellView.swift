//
//  ChartCellView.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartCellView: UIView {
    
    @IBOutlet weak var btnMark: UIButton!
    @IBOutlet weak var vwGraph: UIView!
    @IBOutlet weak var svGraph: UIStackView!
    
    var data:Dictionary<String, Any>? = nil
    var type:PetHealth = .drink
    var category:String? = nil
    var graph:GraphView? = nil
    
    var stDate: Date?
    var edDate: Date?
    let df = CDateFormatter.init()
    var calendar = Calendar.init(identifier: .gregorian)
    var didClickedClosure:((_ selDate: Any?, _ category: String?, _ type:PetHealth, _ index:Int) -> ())? {
        didSet {
        }
    }
    
    func configurationData(category: String?, type: PetHealth) {
        
        self.type = type
        self.category = category
        calendar.locale = Locale.init(identifier: "ko_KR");
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
        
        self.stDate = Date().jumpingDay(jumping: -5)
        edDate = Date()
        
        
        if graph == nil {
            for subview in svGraph.subviews {
                subview.removeFromSuperview()
            }
            graph = GraphView.initWithFromNib()
            svGraph.addArrangedSubview(graph!)
        }
        graph?.stDate = stDate
        graph?.edDate = edDate!
        graph?.configurationGraph(type: .day, colorGraph: color);
        
        self.requestChartData()
    }
    func requestChartData() {
        guard let stDateStr = stDate?.stringDateWithFormat("yyyy-MM-dd") else {
            return
        }
        guard let edDateStr = edDate?.stringDateWithFormat("yyyy-MM-dd") else {
            return
        }
        guard let savePetId = UserDefaults.standard.object(forKey: kMainShowPetId) as? Int  else {
            return
        }
        print("req stDate: \(stDateStr), edDate:\(edDateStr)")
        ApiManager.shared.requestChartData(health: type, petId: savePetId, type: .day, stDate:stDateStr , edDate: edDateStr) { (response) in
            if let response = response as? [String:Any],
               let date = response["data"] as? [String:Any],
               let charts = date["charts"] as? Array<[String:Any]>,
               let maxValue = date["maxValue"] as? NSNumber {
                if let arrChart = self.pickupDayGraphDates(count: 5, selDate: self.edDate!, arrData: charts) {
                    let maxValue = maxValue.floatValue
                    self.graph?.maxValue = maxValue
                    self.graph?.data = arrChart
                    self.graph?.reloadData()
                }
            }
        } failure: { (error) in
            
        }
    }
    
    func pickupDayGraphDates(count:Int, selDate:Date, arrData:Array<[String:Any]>) -> Array<[String:Any]>? {
        df.dateFormat = "yyyy-MM-dd"
        
        let stDay = selDate.jumpingDay(jumping: -(count-1))
        let days = datesRange(unit: .day, from: stDay, to: selDate)
        var result:Array<[String:Any]> = Array<[String:Any]>()
        
        for day in days {
            let findDateStr:String = df.string(from: day)
            var isFind = false
            for item in arrData {
                if let key = item["key"] as? String, key == findDateStr {
                    result.append(item)
                    isFind = true
                }
            }
            if isFind == false {
                //create garbage data
                let garbageData:[String:Any] = ["key": findDateStr, "value1": 0, "value2": 0.0, "etc": ""]
                result.append(garbageData)
            }
        }
        return result
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMark {
            didClickedClosure?(data, category, type, 0)
        }
    }
    
}
