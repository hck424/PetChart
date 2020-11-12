//
//  ChattingCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/05.
//

import UIKit

class ChattingCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    
    var data: Dictionary<String, Any>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        self.selectedBackgroundView = view
        bgView.layer.cornerRadius = 4
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
        guard let data = data else {
            return
        }
        
        if let message = data["message"] as? String {
            lbContent.text = message
        }
        if let dtype = data["dtype"] as? String {
            if dtype == "user" {
                bgView.backgroundColor = ColorDefault
                lbContent.textColor = UIColor.white
                
                if let lbTime = self.getTimeLabel() {   //내가 쓴글
                    svContent.insertArrangedSubview(lbTime, at: 0)
                }
            }
            else {
                bgView.backgroundColor = UIColor.white
                lbContent.textColor = UIColor.black
                
                if let lbTime = self.getTimeLabel() {
                    svContent.addArrangedSubview(lbTime)
                }
            }
        }
    }
    
    func getTimeLabel() -> UILabel? {
        guard let data = data else {
            return nil
        }
        guard let writeDate = data["create_date"] as? String else {
            return nil
        }
        
        let lbTime = UILabel()
        lbTime.backgroundColor = UIColor.clear
        lbTime.font = UIFont.systemFont(ofSize: 12)
        lbTime.textColor = RGB(136, 136, 136)
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy.MM.dd HH:mm:ss"
        
        guard let date = df.date(from: writeDate) else {
            return nil
        }
  
        df.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
        let calendar = Calendar.init(identifier: .gregorian)
        
        if calendar.isDateInToday(date) {
            df.dateFormat = "a hh:mm"
        }
        else {
            df.dateFormat = "yy.MM.dd hh:mm"
        }
        
        let str = df.string(from: date)
        lbTime.text = str
        
        lbTime.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.horizontal)
        lbTime.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.vertical)
        
        if let dtype = data["dtype"] as? String {
            if dtype == "user" {
                lbTime.textAlignment = .right
            }
            else {
                lbTime.textAlignment = .left
            }
        }
        
        return lbTime
    }
}
