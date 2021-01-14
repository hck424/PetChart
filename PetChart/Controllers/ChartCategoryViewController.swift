//
//  ChartCategoryViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import UIKit

class ChartCategoryViewController: BaseViewController {
    @IBOutlet weak var vwBgContainer: UIView!
    @IBOutlet weak var lbYearMonth: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svTopDay: UIStackView!
    @IBOutlet weak var btnMark: UIButton!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var vwGraph: UIView!
    @IBOutlet weak var svGraph: UIStackView!
    
    var arrBtnTopDay: [CButton] = [CButton]()
    
    let TAG_UNDER_LINE: Int = 1234567
    
    var vcTitle:String?
    var type:PetHealth = .drink
    var data: Dictionary<String, Any>?
    var graphType: GraphType = .day
    
    var arrChart:[[String:Any]] = [[String:Any]]()
    var maxValue:Float = 0
    let df = CDateFormatter.init()
    var calendar = Calendar.init(identifier: .gregorian)
    var saveMonth:Int = -1
    var widthTopDay: CGFloat = 0
    var seledButton:CButton? = nil
    var arrPickupGraph:[[String:Any]] = [[String:Any]]()
    var graph: GraphView?
    var selDate:Date = Date()
    var arrDate:[Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        calendar.locale = Locale.init(identifier: "ko_KR")
        
        var title = ""
        if let tt = vcTitle {
            title = tt
        }
        let curDate = Date()
        //3달로 하자
        let fromDate:Date = curDate.jumpingDay(jumping: -150).startOfMonth()
        let toDate:Date = curDate
        
        self.arrDate = datesRange(unit: .day, from: fromDate, to: toDate)
        
        CNavigationBar.drawTitle(self, title, nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        vwBgContainer.layer.cornerRadius = 20
        vwBgContainer.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        vwGraph.layer.borderWidth = 1.0
        vwGraph.layer.borderColor = RGB(239, 239, 239).cgColor
        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        self.view.layoutIfNeeded()
        self.drawTopCalendar()
        self.underLineSelected(btnDay)
        
        let index = self.findIndexWithDate(date: curDate)
        self.changeSeledButton(index: index)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.contentSize.width - self.scrollView.bounds.width, y: 0), animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func drawTopCalendar() {
        for i in 0..<arrDate.count {
            let date = arrDate[i]
            self.makeTopDayButton(date:date, index:i)
        }
    }
    
    func requestChartData(from: String, to: String) {
        
        guard let savePetId = UserDefaults.standard.object(forKey: kMainShowPetId) as? Int  else {
            return
        }
        
        ApiManager.shared.requestChartData(health: type, petId: savePetId, type: graphType, stDate:from , edDate: to) { (response) in
            if let response = response as? [String:Any],
               let date = response["data"] as? [String:Any],
               let charts = date["charts"] as? Array<[String:Any]>,
               let maxValue = date["maxValue"] as? NSNumber {
                self.arrChart.removeAll()
                self.arrChart = charts
                self.maxValue = maxValue.floatValue
                self.configurationUI()
            }
        } failure: { (error) in
            self.showToast("해당일을 선택불가입니다.")
        }
    }
    
    func configurationUI() {
        if arrChart.isEmpty == true {
            return
        }
    
        btnMark.setImage(type.markImage(), for: .normal)
        btnMark.setTitle(type.koreanValue(), for: .normal)
    
        var graphColor = type.colorType()
        if graphColor == nil {
            graphColor = UIColor.black
        }
        
        //그래프 그리기
        for subview in svGraph.subviews {
            subview.removeFromSuperview()
        }
        self.graph = GraphView.initWithFromNib()
        svGraph.addArrangedSubview(graph!)
        
        if graphType == .day {
            graph?.configurationGraph(type: .day, colorGraph: graphColor)
        }
        else if graphType == .week {
            graph?.configurationGraph(type: .week, colorGraph: graphColor)
        }
        else if graphType == .month {
            graph?.configurationGraph(type: .month, colorGraph: graphColor)
        }
        
        if graphType == .day {
            guard let pickData = self.pickupDayGraphDates(count: 5, selDate: selDate, arrData: arrChart) else {
                return
            }
            self.arrPickupGraph = pickData
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.edDate = selDate
            self.graph?.reloadData()
        }
        else if graphType == .week {
            var index = 0
            self.arrPickupGraph.removeAll()
            for item in arrChart {
                self.arrPickupGraph.append(item)
                index += 1
                if index > 4 {
                    break;
                }
            }
            
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.edDate = selDate
            self.graph?.reloadData()
        }
        else if graphType == .month {
            self.arrPickupGraph = arrChart
            self.graph?.maxValue = maxValue
            self.graph?.data = arrPickupGraph
            self.graph?.edDate = selDate
            self.graph?.reloadData()
        }
    }
    
    func makeTopDayButton(date:Date, index:Int) {
        self.widthTopDay = CGFloat((scrollView.bounds.width - 40.0)/5)
        let btn:CButton = CButton.init()
        btn.translatesAutoresizingMaskIntoConstraints = true
        btn.widthAnchor.constraint(equalToConstant: widthTopDay).isActive = true
        
        svTopDay.addArrangedSubview(btn)
        btn.data = date
        btn.tag = index
        
        let index = calendar.component(.weekday, from: date)
        let simbol = calendar.shortWeekdaySymbols[index-1]
        
        let componet = calendar.dateComponents([.month, .day], from: date)
        let curMonth = componet.month!
        let day = componet.day!
        
        let svVertical:UIStackView = UIStackView.init()
        svVertical.axis = .vertical
        svVertical.distribution = .fillEqually
        svVertical.alignment = .center
        btn.addSubview(svVertical)
        
        svVertical.translatesAutoresizingMaskIntoConstraints = false
        svVertical.leadingAnchor.constraint(equalTo: btn.leadingAnchor).isActive = true
        svVertical.topAnchor.constraint(equalTo: btn.topAnchor).isActive = true
        svVertical.bottomAnchor.constraint(equalTo: btn.bottomAnchor).isActive = true
        svVertical.trailingAnchor.constraint(equalTo: btn.trailingAnchor).isActive = true
        svVertical.isUserInteractionEnabled = false
        
        let label = UILabel.init()
        svVertical.addArrangedSubview(label)
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = RGB(136, 136, 136)
        label.tag = 100
        
        label.text = simbol
        let lbDay = UILabel.init()
        lbDay.textAlignment = .center
        lbDay.font = UIFont.systemFont(ofSize: 13)
        lbDay.textColor = UIColor.black
        lbDay.tag = 200
        var widthDay:CGFloat = 35.0
        if widthDay > widthTopDay {
            widthDay = widthTopDay
        }
        lbDay.translatesAutoresizingMaskIntoConstraints = false
        lbDay.widthAnchor.constraint(equalToConstant: widthDay).isActive = true
        lbDay.heightAnchor.constraint(equalToConstant: widthDay).isActive = true
        svVertical.addArrangedSubview(lbDay)
        if curMonth != saveMonth {
            lbDay.text = "\(curMonth)/\(day)"
        }
        else {
            lbDay.text = "\(day)"
        }
        
        lbDay.layer.cornerRadius = CGFloat(widthDay/2.0)
        lbDay.layer.borderColor = UIColor.clear.cgColor
        lbDay.layer.borderWidth = 2.0
       
        saveMonth = curMonth
        
        btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
        arrBtnTopDay.append(btn)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDay {
            graphType = .day
            
            //서버에서 30개씩 내려준다.
            let stDate = selDate.jumpingDay(jumping: -5)
            let from = stDate.stringDateWithFormat("yyyy-MM-dd")
            let to = selDate.stringDateWithFormat("yyyy-MM-dd")
            self.requestChartData(from: from, to: to)
            
            self.underLineSelected(sender)
        }
        else if sender == btnWeek {
            graphType = .week
            let stDate = selDate.jumpingDay(jumping: -35)
            let from = stDate.stringDateWithFormat("yyyy-MM-dd")
            let to = selDate.stringDateWithFormat("yyyy-MM-dd")
            self.requestChartData(from: from, to: to)
            
            self.configurationUI()
            self.underLineSelected(sender)
        }
        else if sender == btnMonth {
            graphType = .month
            
            //5개월전 .jumpingDay(jumping: -240)!
            var year = selDate.getYear()
            var month = selDate.getMonth()
            let day = selDate.getDay()
            let beforeMonth = 4
            if (month - beforeMonth) < 1 {
                year = year - 1
                month = 12-abs(month-beforeMonth)
            }
            else {
                month = month - beforeMonth
            }
            let from = String.init(format: "%04d-%02d-%02d", year, month, day)
            let to = selDate.stringDateWithFormat("yyyy-MM-dd")
            self.requestChartData(from: from, to: to)
            
            self.underLineSelected(sender)
        }
        else if sender == btnDetail {
            let vc = ChartDetailViewController.init(nibName: "ChartDetailViewController", bundle: nil)
            vc.endDate = selDate
            vc.graphType = graphType
            vc.type = type
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnRecord {
            var vc: UIViewController? = nil
            if type == .drink {
                vc = ChartRecordDrinkViewController.init()
            }
            else if type == .eat {
                vc = ChartRecordEatViewController.init()
            }
            else if type == .weight {
                vc = ChartRecordWeightViewController.init()
            }
            else if type == .feces {
                vc = ChartRecordFecesViewController.init()
            }
            else if type == .walk {
                vc = ChartRecordWalkViewController.init()
            }
            else if type == .medical {
                vc = ChartRecordMedicalViewController.init()
            }
            
            if let vc = vc  {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if self.arrBtnTopDay.contains(sender as! CButton) == true {
            let findIndex = sender.tag
            self.changeSeledButton(index: findIndex)
        }
    }
    
    func removeUnderlineView(_ sender: UIButton) {
        if let view = sender.viewWithTag(TAG_UNDER_LINE) {
            view.removeFromSuperview()
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .regular)
        sender.setTitleColor(RGB(145, 145, 145), for: .normal)
    }
    func underLineSelected(_ sender: UIButton) {
        self.removeUnderlineView(btnDay)
        self.removeUnderlineView(btnWeek)
        self.removeUnderlineView(btnMonth)
        
        let underline = UIView.init(frame: CGRect(x: (sender.bounds.width - 20)/2, y: sender.bounds.height/2 + 3, width: 20, height: 8))
        underline.backgroundColor = RGBA(233, 95, 94, 0.5)
        underline.tag = TAG_UNDER_LINE
        sender.addSubview(underline)
        
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .bold)
        sender.setTitleColor(UIColor.black, for: .normal)
    }
    
    func findIndexWithDate(date:Date) -> Int {
        let dateStr = date.stringDateWithFormat("yyyy-MM-dd")
        var findIndex = arrDate.count-1
        for i in 0..<arrDate.count {
            let tmpDate = arrDate[i]
            let tmpDateStr = tmpDate.stringDateWithFormat("yyyy-MM-dd")
            if tmpDateStr == dateStr {
                findIndex = i
                break
            }
        }
        return findIndex
    }
    func changeSeledButton(index:Int) {
        if let seledButton = seledButton {
            if let lbDate = seledButton.viewWithTag(200) as? UILabel {
                lbDate.font = UIFont.systemFont(ofSize: 13)
                lbDate.textColor = UIColor.black
                lbDate.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        self.seledButton = arrBtnTopDay[index]
        if let lbDate = self.seledButton!.viewWithTag(200) as? UILabel {
            lbDate.font = UIFont.systemFont(ofSize: 13, weight: .bold)
            lbDate.textColor = ColorDefault
            lbDate.layer.borderColor = ColorDefault.cgColor
        }
        
        let widthCenter = CGFloat(2*widthTopDay)
        let offsetX = CGFloat(CGFloat(index)*widthTopDay - widthCenter)
        
        if (offsetX <= scrollView.contentSize.width - scrollView.bounds.width)
            && (offsetX >= 0) {
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
        
        self.arrPickupGraph.removeAll()
        
        guard let selData = seledButton?.data as? Date else {
            return
        }

        self.selDate = selData
        
        df.dateFormat = "yyyy.MM"
        let strYearMonth = df.string(from: selDate)
        lbYearMonth.text = strYearMonth
        
        if graphType == .day {
            btnDay.sendActions(for: .touchUpInside)
        }
        else if graphType == .week {
            btnWeek.sendActions(for: .touchUpInside)
        }
        else if graphType == .month {
            btnMonth.sendActions(for: .touchUpInside)
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

}

extension ChartCategoryViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("=== didend decelerating")
        let offsetX = scrollView.contentOffset.x + scrollView.bounds.width/2
        let findIndex = Int(offsetX/widthTopDay)
        self.changeSeledButton(index: findIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let offsetX = scrollView.contentOffset.x + scrollView.bounds.width/2
            let findIndex = Int(offsetX/widthTopDay)
            self.changeSeledButton(index: findIndex)
        }
    }
}
