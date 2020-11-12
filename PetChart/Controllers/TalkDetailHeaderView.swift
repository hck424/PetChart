//
//  TalkDetailHeaderView.swift
//  PetChart
//
//  Created by 김학철 on 2020/11/08.
//

import UIKit
enum HearderActionType {
    case reload, like, report, back, touchIcon
}

class TalkDetailHeaderView: UIView {

    @IBOutlet weak var ivTopThumb: AligmentImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var lbNickName: UILabel!
    @IBOutlet weak var lbAnimalInfo: UILabel!
    @IBOutlet weak var lbTalkTitle: UILabel!
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var svImages: UIStackView!
    @IBOutlet weak var lbTalkContent: UILabel!
    
    @IBOutlet weak var heightContent: NSLayoutConstraint!
    
    var tapGesture:UITapGestureRecognizer? = nil
    var dataDic:[String:Any]?
    var imageCount = 0
    var constraintImgs:[NSLayoutConstraint] = [NSLayoutConstraint]()
    var didCloureActions:((_ actionIndex:HearderActionType)->())? {
        didSet {
            
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configurationData(_ data:[String:Any]?) {
        self.dataDic = data
        ivProfile.layer.borderWidth = 2.0
        ivProfile.layer.borderColor = RGB(239, 239, 239).cgColor
        ivProfile.layer.cornerRadius = ivProfile.bounds.height/2
        
        if let tapGesture = tapGesture {
            ivProfile.removeGestureRecognizer(tapGesture)
        }
        
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        ivProfile.addGestureRecognizer(tapGesture!)
        
        ivTopThumb.verticalAlignment = .top
        
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        guard let dataDic = self.dataDic else {
            return
        }
        
        if let content = dataDic["content"] as? String{
            lbTalkContent.text = content
            let height:CGFloat = lbTalkContent.sizeThatFits(CGSize.init(width: lbTalkContent.bounds.width, height: CGFloat.infinity)).height
            heightContent.constant = height
        }
       
        if let icon_url = dataDic["icon_url"] as? String {
            ivProfile.setImageCache(url: icon_url, placeholderImgName: nil)
        }
        btnLike.isSelected = false
        if let my_like_state = dataDic["my_like_state"] as? String {
            if my_like_state == "like" {
                btnLike.isSelected = true
            }
        }
        if let nickname = dataDic["nickname"] as? String {
            lbNickName.text = nickname
        }
        if let tag = dataDic["tag"] as? String {
            lbCategory.text = tag
        }
        if let title = dataDic["title"] as? String {
            lbTalkTitle.text = title
        }
        lbAnimalInfo.text = ""
        if let mainPet = dataDic["main_pet"] as? [String:Any] {
            var result = ""
            if let petName = mainPet["petName"] as? String {
                result.append(petName)
            }
            if let animalAge = mainPet["animalAge"] as? Int {
                result.append(" / \(animalAge)세")
            }
            if let animalSex = mainPet["animalSex"] as?String, animalSex == "M" {
                result.append(" 남아")
            }
            else {
                result.append(" 여아")
            }
            lbAnimalInfo.text = result
        }
        
        svImages.isHidden = true
        if let images = dataDic["images"] as? Array<[String:Any]> {
            svImages.isHidden = false
            if svImages.subviews.count == 0 {
                //최상단에 있는놈 뺀다.
                for i in 0..<images.count {
                    if let item = images[i] as? [String:Any], let original = item["original"] as? String {
                        
                        let ivThumnail = AligmentImageView.init()
                        ivThumnail.horizontalAlignment = .center
                        ivThumnail.verticalAlignment = .top
                        
                        ivThumnail.clipsToBounds = true
                        
                        svImages.addArrangedSubview(ivThumnail)
                        ivThumnail.contentMode = .scaleAspectFill
                        ivThumnail.translatesAutoresizingMaskIntoConstraints = false
                        
                        let userInfo:[String : Any] = ["targetView":ivThumnail, "index":(i)]
                        
                        ImageCache.downLoadImg(url: original, userInfo: userInfo) { (image, userInfo) in
                            if let image = image, let userInfo = userInfo  {
                                let height:CGFloat = ((self.svImages.bounds.width-40) * image.size.height)/image.size.width
                                if let targetView = userInfo["targetView"] as? UIImageView, let index = userInfo["index"] as? Int {
                                    targetView.image = image
                                    
                                    let constraint = targetView.heightAnchor.constraint(equalToConstant: height)
                                    constraint.priority = UILayoutPriority(rawValue: 900)
                                    constraint.isActive = true
                                    constraint.identifier = "image_height"
                                    self.constraintImgs.append(constraint)
                                    self.imageCount += 1
                                    if self.imageCount == images.count {
                                        //마지막 놈까지 다 다운 로드 됐다면 테이블 뷰 릴로드 해준다.
                                        //안그러면 헤더의 사이즈가 맞지 않는 문제가 발생
                                        self.didCloureActions?(.reload)
                                    }
                                    print("=== imgSize:\(image.size), height:\(height), index:\(index)")
                                }
                            }
                        }
                    }
                }
            }
        }
    
        
        if let users_id = dataDic["users_id"] as? Int {
            if users_id == SharedData.instance.userIdx {
                btnReport.isHidden = true
            }
            else {
                btnReport.isHidden = false
            }
        }
    }
    @objc func tapGestureHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == ivProfile {
            didCloureActions?(.touchIcon)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnBack {
            didCloureActions?(.back)
        }
        else if sender == btnLike {
            didCloureActions?(.like)
        }
        else if sender == btnReport {
            didCloureActions?(.report)
        }
    }
    
}
