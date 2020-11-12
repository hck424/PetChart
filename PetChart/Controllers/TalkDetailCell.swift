//
//  TalkDetailCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

class TalkDetailCell: UITableViewCell {

    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lbContent: UILabel!
    
    var data: Dictionary<String, Any>?
    var didSelectActionClosure:((_ selData: Dictionary<String, Any>?, _ actionIndex:Int) ->())? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ivProfile.layer.borderWidth = 1.0
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        ivProfile.backgroundColor = UIColor.white
        
        ivProfile.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        ivProfile.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
//        ["post_id": 0, "content": 테스, "update_date": 2020.10.31 01:33:16, "id": 7, "create_date": 2020.10.31 01:33:16, "user_id": 2, "nickname": 테스트식1]
        
        lbNickName.text = ""
        lbTime.text = ""
        lbContent.text = ""
        
        btnDelete.isHidden = true
        ivProfile.image = nil
        
        guard let data = self.data else {
            return
        }
        if let user_id = data["user_id"] as? Int {
            if user_id == SharedData.instance.userIdx {
                btnDelete.isHidden = false
            }
        }
        
        if let nickname = data["nickname"] as? String {
            lbNickName.text = nickname
        }
        if let content = data["content"] as? String {
            lbContent.text = content
        }
        
        if let icon_url = data["icon_url"] as? String {
            ivProfile.setImageCache(url: icon_url, placeholderImgName: nil)
        }
        
        
        
        if let update_date = data["create_date"] as? String {
            let df = CDateFormatter.init()
            df.dateFormat = "yyyy.MM.dd HH:mm:ss"
           
            if let date = df.date(from: update_date) {
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
            }
        }
    }
    @objc func tapGestureHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == ivProfile {
            self.didSelectActionClosure?(data, 1)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnDelete {
            self.didSelectActionClosure?(data, 0)
        }
    }
}
