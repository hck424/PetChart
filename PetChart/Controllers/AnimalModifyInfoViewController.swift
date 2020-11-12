//
//  AnimalModifyInfoViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
import Photos
class AnimalModifyInfoViewController: BaseViewController {

    @IBOutlet weak var btnProfile: CButton!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var tfBirthDay: CTextField!
    @IBOutlet weak var btnBirthDay: UIButton!
    @IBOutlet weak var btnMale: SelectedButton!
    @IBOutlet weak var btnFemale: SelectedButton!
    
    @IBOutlet weak var btnDog: SelectedButton!
    @IBOutlet weak var btnCat: SelectedButton!
    @IBOutlet weak var btnOther: SelectedButton!
    @IBOutlet weak var tfItem: CTextField!
    @IBOutlet weak var btnArrowItem: UIButton!
    @IBOutlet weak var btnPreventionBefore: SelectedButton!
    @IBOutlet weak var btnPreventionAfter: SelectedButton!
    @IBOutlet weak var btnPreventionNone: SelectedButton!
    @IBOutlet weak var btnPreNeutral: SelectedButton!
    @IBOutlet weak var btnAfeterNeutral: SelectedButton!
    @IBOutlet weak var tfRegiNumber: CTextField!
    @IBOutlet weak var btnEmptyRegiNumber: SelectedButton!
    @IBOutlet weak var btnAnswerRegiNum: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    
    var profileImg: UIImage?
    var animal: Animal?
    var dtype:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 정보수정", nil)

        
        if Utility.isIphoneX() == false {
            btnSafety.isHidden = true
        }
        
        tfName.inputAccessoryView = accessoryView
        tfRegiNumber.inputAccessoryView = accessoryView
        
        btnProfile.layer.cornerRadius = btnProfile.bounds.height/2
        btnProfile.imageView?.contentMode = .scaleAspectFit
        btnProfile.layer.borderWidth = 2
        btnProfile.layer.borderColor = RGB(222, 222, 222).cgColor
        btnAnswerRegiNum.imageView?.contentMode = .scaleAspectFit
        self.requestPetDetailInfo()
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

    func requestPetDetailInfo() {
        ApiManager.shared.requestPetDetailInfo(petId: (animal?.id)!) { (response) in
            if let response = response as?[String: Any], let data = response["data"] as?[String:Any] {
                self.animal = Animal.init(JSON: data)
                self.decorationUi()
            }
            else {
                self.decorationUi()
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func decorationUi() {
        guard let animal = animal else {
            return
        }
        
        if let images = animal.images, let imageInfo = images.first, let original = imageInfo.original {
            ImageCache.downLoadImg(url: original, userInfo: nil) { (image, userInfo) in
                if let image = image {
                    self.btnProfile.setImage(image, for: .normal)
                }
            }
        }
        tfName.text = animal.petName
        tfBirthDay.text = animal.birthday
        
        if let sex = animal.sex, sex == "M" {
            btnMale.isSelected = true
        }
        else {
            btnFemale.isSelected = true
        }
        
        self.dtype = animal.dtype
        if dtype! == "puppy" {
            btnDog.isSelected = true
        }
        else if dtype! == "cat" {
            btnCat.isSelected = true
        }
        else {
            btnOther.isSelected = true
        }
        
        if let kind = animal.kind {
            tfItem.text = kind
        }
        
        if let prevention = animal.prevention {
            if prevention == "Y" {
                btnPreventionAfter.isSelected = true
            }
            else if prevention == "N" {
                btnPreventionBefore.isSelected = true
            }
            else {
                btnPreventionNone.isSelected = true
            }
        }
        
        if let neutral = animal.neutral {
            if neutral == "Y" {
                btnAfeterNeutral.isSelected = true
            }
            else {
                btnPreNeutral.isSelected = true
            }
        }
        
        if let regist_id = animal.regist_id {
            tfRegiNumber.text = regist_id
        }
    }
    @IBAction func textFieldEdtingChnaged(_ sender: UITextField) {
        if sender == tfRegiNumber && sender.text?.isEmpty == false {
            btnEmptyRegiNumber.isSelected = false
        }
    }
    
    //FIXME:: button actions
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if sender == btnBirthDay {
            let picker = CDatePickerView.init(type: .yearMonthDay, minDate: Date().getStartDate(withYear: -30), maxDate: Date(), apointDate: Date()) { (strDate, date) in
                if let strDate = strDate {
                    self.tfBirthDay.text = strDate
                }
            }
            picker?.local = Locale(identifier: "ko_KR")
            picker?.show()
        }
        else if sender == btnArrowItem {
            guard let dtype = dtype else {
                return
            }
            
            ApiManager.shared.requestAnimalKinds(dtype: dtype) { (response) in
                if let response = response as? [String:Any],
                   let success = response["success"] as? Bool,
                   let list = response["list"] as? Array<String>  {
                    
                    if success && list.isEmpty == false {
                        let vc = PopupListViewController.init(type: .normal, title: "품종을 선택해주세요.", data: list, keys: nil) { (vcs, selData:Any?, index) in
                            if let selData = selData as?String {
                                self.tfItem.text = selData
                            }
                            vcs.dismiss(animated: true, completion: nil)
                        }
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            } failure: { (error) in
                self.showErrorAlertView(error)
            }
        }
        else if sender == btnPreventionBefore {
            btnPreventionBefore.isSelected = true
            btnPreventionAfter.isSelected = false
            btnPreventionNone.isSelected = false
        }
        else if sender == btnPreventionAfter {
            btnPreventionBefore.isSelected = false
            btnPreventionAfter.isSelected = true
            btnPreventionNone.isSelected = false
        }
        else if sender == btnPreventionNone {
            btnPreventionBefore.isSelected = false
            btnPreventionAfter.isSelected = false
            btnPreventionNone.isSelected = true
        }
        else if sender == btnMale {
            btnMale.isSelected = true
            btnFemale.isSelected = false
        }
        else if sender == btnFemale {
            btnMale.isSelected = false
            btnFemale.isSelected = true
        }
        else if sender == btnDog {
            btnDog.isSelected = true
            btnCat.isSelected = false
            btnOther.isSelected = false
            self.dtype = "puppy"
            tfItem.text = ""
        }
        else if sender == btnCat {
            btnDog.isSelected = false
            btnCat.isSelected = true
            btnOther.isSelected = false
            self.dtype = "cat"
            tfItem.text = ""
        }
        else if sender == btnOther {
            btnDog.isSelected = false
            btnCat.isSelected = false
            btnOther.isSelected = true
            self.dtype = "etc"
            tfItem.text = ""
        }
        else if sender == btnPreNeutral {
            btnPreNeutral.isSelected = true
            btnAfeterNeutral.isSelected = false
            print("pre neutral")
        }
        else if sender == btnAfeterNeutral {
            btnPreNeutral.isSelected = false
            btnAfeterNeutral.isSelected = true
            print("after neutral")
        }
        else if sender == btnEmptyRegiNumber {
            sender.isSelected = true
            tfRegiNumber.text = ""
            print("empty regist number")
        }
        else if sender == btnAnswerRegiNum {
            let vc = AnimalRegiNumberInfoViewController.init()
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if sender == btnProfile {
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
        else if sender == btnOk {
            guard let petId = animal?.id else {
                return
            }
            
            if tfBirthDay.text?.isEmpty == true {
                self.view.makeToast("생년월일을 입력해주세요.")
                return
            }
            if tfItem.text?.isEmpty == true {
                self.view.makeToast("품종을 입력해주세요")
            }
            
         
            var param:[String:Any] = [String:Any]()
            if let profileImg = profileImg {
                param["images"] = [profileImg]
            }
            
            param["name"] = tfName.text!
            param["birthday"] = tfBirthDay.text!
            if btnPreNeutral.isSelected {
                param["neutral"] = "N"
            }
            else if btnAfeterNeutral.isSelected {
                param["neutral"] = "Y"
            }
            
            if btnPreventionBefore.isSelected {
                param["prevention"] = "N"
            }
            else if btnPreventionAfter.isSelected {
                param["prevention"] = "Y"
            }
            else {
                param["prevention"] = "D"
            }
            if let dtype = dtype { param["dtype"] = dtype }
            
            if tfRegiNumber.text?.isEmpty == false {
                param["regist_id"] = tfRegiNumber.text!
            }
            
            if btnMale.isSelected {
                param["sex"] = "M"
            }
            else {
                param["sex"] = "F"
            }
            
            if tfItem.text?.isEmpty == false {
                param["kind"] = tfItem.text!
            }
            
            let df = CDateFormatter.init()
            df.dateFormat = "yyyy-MM-dd"
            let birthday = df.date(from: tfBirthDay.text!)
            let ageInfo = self.getAgeInfo(birthDay: birthday!)
            param["age"] = ageInfo.year
            param["id"] = petId
            ApiManager.shared.requestPetInfoModify(param: param) { (response) in
                if let response = response as? [String:Any],
                   let success = response["success"] as? Bool,
                   let data = response["data"] as? [String:Any],
                   let petName = data["petName"] as? String {
                    if success && data.isEmpty == false {
                        AlertView.showWithOk(title: petName, message: "수정이 완료되었습니다.") { (idex) in
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    else {
                        self.showErrorAlertView(response)
                    }
                }
            } failure: { (error) in
                self.showErrorAlertView(error)
            }

        }
    }

    func showCamera(_ sourceType: UIImagePickerController.SourceType) {
        let vc = CameraViewController.init()
        vc.delegate = self
        vc.sourceType = sourceType
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func getAgeInfo(birthDay:Date) -> DateComponents {
        let now = Date()
        var calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale.init(identifier: "en_US_POSIX")
        let componets = calendar.dateComponents([.year, .month,.day], from: birthDay, to: now)
        return componets
    }
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            bottomContainer.constant = heightKeyboard - (AppDelegate.instance()?.window?.safeAreaInsets.bottom)! - btnOk.bounds.height
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

}
extension AnimalModifyInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension AnimalModifyInfoViewController: CameraViewControllerDelegate {
    func didFinishImagePickerAssets(_ assets: [PHAsset]?) {
        guard let assets = assets else {
            return
        }
        guard let asset = assets.first else { return }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: PHImageRequestOptions()) { (result, _) in
            guard let result = result else {
                return
            }
            self.profileImg = result
            self.btnProfile.setImage(self.profileImg, for: .normal)
            self.btnProfile.borderColor = RGB(217, 217, 217)
            self.btnProfile.borderWidth = 2.0
            self.btnProfile.setNeedsDisplay()
        }
    }
    
    func didFinishImagePicker(origin: UIImage?, crop: UIImage?) {
        self.profileImg = crop
        self.btnProfile.setImage(self.profileImg, for: .normal)
        self.btnProfile.borderColor = RGB(217, 217, 217)
        self.btnProfile.borderWidth = 2.0
        self.btnProfile.setNeedsDisplay()
    }
}
