//
//  TalkCell.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

class TalkCell: UITableViewCell {
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lbMsg: UILabel!
    @IBOutlet weak var lbAnimalKind: UILabel!
    @IBOutlet weak var lbReplyCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var data: Dictionary<String, Any>? = nil
    var didClickedActionClosure:((_ selData:Dictionary<String, Any>?, _ btnAction:Int)->())? {
        didSet { }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        ivThumb.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        ivThumb.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data: Dictionary<String, Any>?) {
        self.data = data
        ivThumb.layer.cornerRadius = 2.0
        ivThumb.clipsToBounds = true
        ivThumb.contentMode = .scaleAspectFit
        ivThumb.layer.borderColor = RGB(243, 243, 243).cgColor
        ivThumb.layer.borderWidth = 0.5
        
        //        images =             (
        //                            {
        //                id = 49;
        //                itype = jpg;
        //                original = "https://jayutest.best:5001/images/pets/9c2bf17a-343a-45ba-a1c7-44fe6e787cf9.jpg";
        //                thumbnail = "https://jayutest.best:5001";
        //            }
        //        );
        lbMsg.text = ""
        lbAnimalKind.text = ""
        lbReplyCount.text = "댓글 0"
        btnLike.isSelected = false
        ivThumb.image = nil
        
        guard let data = self.data else {
            return
        }
        
        if let comments_cnt = data["comments_cnt"] as? Int {
            lbReplyCount.text = "댓글 \(comments_cnt)"
        }
        if let images = data["images"] as? Array<Any>, images.isEmpty == false {
            let randomIndex:Int = 0
//            if images.count > 1 {
//                randomIndex = Int(arc4random_uniform(UInt32(images.count)))
//                if randomIndex >= images.count {
//                    randomIndex -= 1
//                }
//            }
            if let item = images[randomIndex] as?[String:Any], let original = item["original"] as? String {
                ivThumb.setImageCache(url: original, placeholderImgName: nil)
            }
        }
        if let my_like_state = data["my_like_state"] as? String {
            if my_like_state == "like" {
                btnLike.isSelected = true
            }
        }
        if let nickname = data["nickname"] as? String, let tag = data["tag"] as? String {
            lbAnimalKind.text = "\(tag) / \(nickname)"
        }
        if let title = data["title"] as? String {
            lbMsg.text = title
        }
//        if let update_date = data["update_date"] as? String {
//
//        }
//        if let create_date = data["create_date"] as? String {
//
//        }
//        if let id = data["id"] as? Int {
//
//        }
    }
    @objc func tapGestureHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == ivThumb {
            self.didClickedActionClosure?(data, 1)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnLike {
            self.didClickedActionClosure?(data, 0)
        }
    }
}
