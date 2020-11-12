//
//  TalkWriteViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit
import Photos
enum TalkWriteVCType {
    case write, modify
}
protocol TalkWriteViewControllerDelegate {
    func didfinishWrite(category:String, data:[String:Any]?)
}

class TalkWriteViewController: BaseViewController {
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var tfTitle: CTextField!
    @IBOutlet var arrBtnImage: [UIButton]!
    @IBOutlet weak var textView: CTextView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnRegist: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var btnKeyboardDown: UIBarButtonItem!
    
    var delegate: TalkWriteViewControllerDelegate?
    var selBtnImg: UIButton? = nil
    
    var arrCategory = ["강아지", "고양이", "기타"]
    var type:TalkWriteVCType = .write
    var modifyData:[String:Any]?
    var snapshot: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawTitle(self, "글쓰기", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        arrBtnImage = arrBtnImage.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        textView.placeHolderString = "내용을 입력해주세요."
        for btn in arrBtnImage {
            btn.addTarget(self, action: #selector(onclickedButtonActins(_:)), for: .touchUpInside)
            
            if let delBtn = btn.viewWithTag(100) as? UIButton {
                delBtn.addTarget(self, action: #selector(onclickedButtonActins(_:)), for: .touchUpInside)
                delBtn.isHidden = true
            }
            
            if let imgView = btn.viewWithTag(200) as? UIImageView {
                imgView.backgroundColor = UIColor.clear
                imgView.contentMode = .scaleAspectFit
            }
            
            btn.setImage(UIImage(named: "ico_pic_add"), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets.init(top: 21, left: 21, bottom: 21, right: 21)
            btn.layer.cornerRadius = 4.0
            btn.clipsToBounds = true
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        self.view.addGestureRecognizer(tap)
        tfTitle.inputAccessoryView = accessoryView
        textView.inputAccessoryView = accessoryView
        
        if type == .modify {
            self.configurationUi()
        }
        if let snapshot = snapshot {
            arrCategory.insert("차트 공유해요", at: 0)
            tfCategory.text = arrCategory.first
            let btn = arrBtnImage[0]
            if let imageView = btn.viewWithTag(200) as? UIImageView {
                imageView.image = snapshot
            }
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if textView.text.isEmpty == false {
            textView.placeholderLabel?.isHidden = true
        }
        else {
            textView.placeholderLabel?.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func tapGestureHandler(_ gesture:UITapGestureRecognizer) {
        if gesture.view == self.view {
            self.view.endEditing(true)
        }
    }
    
    func configurationUi() {
        guard let modifyData = modifyData else {
            return
        }
        
        if let tag = modifyData["tag"] as? String {
            tfCategory.text = tag
            btnCategory.isUserInteractionEnabled = false
        }
        if let title = modifyData["title"] as? String {
            tfTitle.text = title
        }
        if let content = modifyData["content"] as? String {
            self.textView.text = content
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                //viewdidload 에서 placeholder 생성되는 시점 때문에
                self.textViewDidChange(self.textView)
            }
        }
        if let images = modifyData["images"] as? Array<Any> {
            for i in 0..<images.count {
                if let item = images[i] as? [String:Any], let original = item["original"] as? String {
                    let btn = arrBtnImage[i]
                    if let imageView = btn.viewWithTag(200) as? UIImageView {
                        imageView.setImageCache(url: original, placeholderImgName: nil)
                    }
                }
            }
        }
    }
    @IBAction func onClickedKeyboardDown(_ sender: Any) {
        self.view.endEditing(true)
    }
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnCategory {
            let vc = PopupListViewController.init(type: .normal, title: "선택해주세요.", data: arrCategory, keys: nil) { (vcs, selDate, index) in
                
                if let selDate = selDate as? String {
                    self.tfCategory.text = selDate
                }
                vcs.dismiss(animated: false, completion: nil)
            }
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: false, completion: nil)
        }
        else if sender == btnCancel {
            AlertView.showWithCancelAndOk(title: "글쓰기 취소", message: "정말 취소하시겠습니까?\n작성된 내용은 저장되지 않습니다.") { (index) in
                if index == 1 {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
        else if sender == btnRegist {
            
            guard let tag = tfCategory.text, tag.isEmpty == false else {
                self.view.makeToast("카테고리를 선정해 주세요.", duration:1.0, position:.top)
                return
            }
            
            
            guard let title = tfTitle.text, title.isEmpty == false else {
                self.view.makeToast("타이틀을 입력해주세요.", duration:1.0, position:.top)
                return
            }
            
            guard let content = textView.text, content.isEmpty == false else {
                self.view.makeToast("컨텐즈 내용을 입력해주세요.", duration:1.0, position:.top)
                return
            }
            
            var arrImg:Array<UIImage> = Array<UIImage>()
            for btn in arrBtnImage {
                if let ivImage = btn.viewWithTag(200) as? UIImageView, let img = ivImage.image {
                    arrImg.append(img)
                }
            }
            guard arrImg.isEmpty == false else {
                self.view.makeToast("이미지 한장을 필수 입니다.", duration:1.0, position:.top)
                return
            }
            
            
//            한국토지주택공사(LH)는 신종 코로나바이러스 감염증(코로나19) 장기화로 어려움을 겪는 산업단지 입주 중소기업 및 소상공인을 지원하기 위해 임대료 인하기간을 연장한다고 2일 밝혔다.LH는 지난 상반기 전국의 임대산업단지 및 판교제2테크노밸리 내 공공지원건축물 등 LH가 관리하는 산업단지에 입주한 중소기업 및 소상공인을 대상으로 임대료를 6개월 동안 25% 인하한 바 있다.
            if type == .modify {
                guard let modifyData = modifyData, let board_id = modifyData["id"] as? Int else {
                    return
                }
                let param:[String:Any] = ["board_id":board_id, "title":title, "content":content, "images": arrImg]
                AlertView.showWithCancelAndOk(title: "내 게시글 변경", message: "변경 하시겠습니까?") { (index) in
                    if index == 1 {
                        self.requestModifyPost(param:param)
                    }
                }
            }
            else {
                let param:[String:Any] = ["title":title, "content":content, "images": arrImg, "tag": tag]
                AlertView.showWithCancelAndOk(title: "내 게시글 등록", message: "등록하시겠습니꺄?") { (index) in
                    if index == 1 {
                        self.requestWritePost(param:param)
                    }
                }
            }
        }
        else if sender.tag > 0 {
            selBtnImg = sender
            if sender.tag <= 5 {
                let alert = UIAlertController.init(title: nil, message: nil, preferredStyle:.actionSheet)
                alert.addAction(UIAlertAction.init(title: "카메라", style: .default, handler: { (action) in
                    self.showCamera(UIImagePickerController.SourceType.camera)
                    alert.dismiss(animated: false, completion: nil)
                }))
                alert.addAction(UIAlertAction.init(title: "캘러리", style: .default, handler: { (action) in
                    self.showCamera(UIImagePickerController.SourceType.photoLibrary)
                    alert.dismiss(animated: false, completion: nil)
                }))
                alert.addAction(UIAlertAction.init(title: "취소", style: .cancel, handler: { (action) in
                    alert.dismiss(animated: false, completion: nil)
                }))
                present(alert, animated: false, completion: nil)
            }
            else if sender.tag == 100 { //delete btn
                if let btn = sender.superview as? UIButton {
                    if let imageView = btn.viewWithTag(200) as? UIImageView {
                        imageView.image = nil
                    }
                    sender.isHidden = true
                }
            }
        }
    }
    func requestModifyPost(param:[String:Any]) {
        ApiManager.shared.requestModifyMyPost(param: param) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let success = response["success"] as? Bool {
                if success && data.isEmpty == false {
                    self.delegate?.didfinishWrite(category: self.tfCategory.text!, data: data)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }

    }
    func requestWritePost(param:[String:Any]) {
        ApiManager.shared.requestWritePost(param: param) { (response) in
            if let response = response as? [String:Any],
               let data = response["data"] as? [String:Any],
               let success = response["success"] as? Bool {
                if success && data.isEmpty == false {
                    self.view.makeToast("게시글 등록이 완료되었습니다.", duration:1.0, position:.top)
                    self.delegate?.didfinishWrite(category: self.tfCategory.text!, data: data)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorAlertView(response)
                }
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            bottomContainer.constant = heightKeyboard
            UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                self.view.layoutIfNeeded()
            })
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContainer.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func showCamera(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CameraViewController.init()
        vc.delegate = self
        vc.sourceType = sourceType
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension TalkWriteViewController: CameraViewControllerDelegate {
    func didFinishImagePickerAssets(_ assets: [PHAsset]?) {
        guard let assets = assets else {
            return
        }
        
        var i = 0
        for asset in assets {
            let btn = arrBtnImage[i]
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: PHImageRequestOptions()) { (result, _) in
                guard let result = result else {
                    return
                }
                if let imgView = btn.viewWithTag(200) as? UIImageView {
                    imgView.image = result
                }
                if let btnDel = btn.viewWithTag(100) as? UIButton {
                    btnDel.isHidden = false
                }
            }
            i += 1
        }
    }
    func didFinishImagePicker(origin: UIImage?, crop: UIImage?) {
        if let selBtnImg = selBtnImg {
            if let imgView = selBtnImg.viewWithTag(200) as? UIImageView {
                imgView.image = crop
            }
            if let btnDel = selBtnImg.viewWithTag(100) as? UIButton {
                btnDel.isHidden = false
            }
        }
    }
}

extension TalkWriteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
}
