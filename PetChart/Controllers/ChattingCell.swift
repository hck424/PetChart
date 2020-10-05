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
        
        if let content = data["content"] as? String {
            lbContent.text = content
        }
        
        if let type = data["type"] as? String, let lbTime = self.getTimeLabel() {
            if type == "send" {
                bgView.backgroundColor = ColorDefault
                svContent.insertArrangedSubview(lbTime, at: 0)
                lbContent.textColor = UIColor.white
            }
            else {
                bgView.backgroundColor = UIColor.white
                svContent.addArrangedSubview(lbTime)
                lbContent.textColor = UIColor.black
            }
        }
    }
    
    func getTimeLabel() -> UILabel? {
        guard let data = data else {
            return nil
        }
        guard let writeDate = data["writeDate"] as? String else {
            return nil
        }
        
        let lbTime = UILabel()
        lbTime.backgroundColor = UIColor.clear
        lbTime.font = UIFont.systemFont(ofSize: 12)
        lbTime.textColor = RGB(136, 136, 136)
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyyMMdd HH:mm:ss"
        let date = df.date(from: writeDate)
        
        df.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
        df.dateFormat = "a hh:mm"
        let str = df.string(from: date!)
        lbTime.text = str
        
        lbTime.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.horizontal)
        lbTime.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.vertical)
        
        if let type = data["type"] as? String {
            if type == "send" {
                lbTime.textAlignment = .right
            }
            else {
                lbTime.textAlignment = .left
            }
        }
        
        return lbTime
    }
}
