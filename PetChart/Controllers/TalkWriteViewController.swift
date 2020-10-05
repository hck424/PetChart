//
//  TalkWriteViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit

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
    
    var selBtnImg: UIButton? = nil
    
    let arrCategory = ["강아지", "고양이", "기타"]
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawTitle(self, "글쓰기", nil)
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        
        arrBtnImage = arrBtnImage.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
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
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        
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
         
            //TODO:: validate check write
            
            
            AlertView.showWithCancelAndOk(title: "내 글 등록", message: "등록하시겠습니꺄?") { (index) in
                if index == 1 {
                    
                    //writeing
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
