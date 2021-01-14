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
    @IBOutlet weak var cornerBgView: UIView!
    
    @IBOutlet weak var btnDog: SelectedButton!
    @IBOutlet weak var btnCat: SelectedButton!
    @IBOutlet weak var btnOther: SelectedButton!
    @IBOutlet weak var tfItem: UITextField!
    @IBOutlet weak var btnItem: UIButton!
    
    @IBOutlet weak var btnPrevent: UIButton!
    @IBOutlet weak var tfPrevent: UITextField!
    @IBOutlet weak var btnPreNeutral: SelectedButton!
    @IBOutlet weak var btnAfeterNeutral: SelectedButton!
    @IBOutlet weak var tfRegiNumber: CTextField!
    @IBOutlet weak var btnEmptyRegiNumber: SelectedButton!
    @IBOutlet weak var btnAnswerRegiNum: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var tfWeight: CTextField!
    
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
        tfWeight.inputAccessoryView = accessoryView
        
        btnProfile.layer.cornerRadius = btnProfile.bounds.height/2
        btnProfile.imageView?.contentMode = .scaleAspectFill
        
        btnAnswerRegiNum.imageView?.contentMode = .scaleAspectFit
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
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
                tfPrevent.text = "접종 후"
            }
            else if prevention == "N" {
                tfPrevent.text = "접종 전"
            }
            else {
                tfPrevent.text = "모름"
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
        
        if let weight = animal.weight {
            let w = CGFloat(Double(weight)/1000)
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 1
            formatter.numberStyle = .decimal
            formatter.roundingMode = .halfEven
            tfWeight.text = formatter.string(from: w as NSNumber)
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
        else if sender == btnItem {
            guard let dtype = dtype else {
                return
            }
            
            ApiManager.shared.requestAnimalKinds(dtype: dtype) { (response) in
                if let response = response as? [String:Any],
                   let success = response["success"] as? Bool,
                   var list = response["list"] as? Array<String>  {
                    
                    if success && list.isEmpty == false {
                        list.insert("모름", at: 0)
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
        else if sender == btnPrevent {
            let list = ["접종 전", "접종 후", "모름"]
            let vc = PopupListViewController.init(type: .normal, title: nil, data: list, keys: nil) { (vcs, selData, index) in
                vcs.dismiss(animated: false, completion: nil)
                guard let selData = selData as? String else {
                    return
                }
                self.tfPrevent.text = selData
            }
            self.present(vc, animated: true, completion: nil)
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
            self.view.endEditing(true)
            
            guard let petId = animal?.id else {
                return
            }
            
            guard let name = tfName.text, name.isEmpty == false else {
                self.showToast("이름을 입력해주세요.")
                return
            }
            guard let birthday = tfBirthDay.text, birthday.isEmpty == false else {
                self.showToast("생년월일을 선택해주세요.")
                return
            }
            
            guard let item = tfItem.text, item.isEmpty == false else {
                self.showToast("품종을 선택해주세요.")
                return
            }
            
            guard let weight = tfWeight.text, weight.isEmpty == false else {
                self.showToast("몸무게를 입력해주세요.")
                return
            }
            if Float(weight)! > 200 {
                self.view.makeToast("몸무게는 최대 200kg까지 입력가능합니다.")
                return
            }
            var param:[String:Any] = [String:Any]()
            if let profileImg = profileImg {
                param["images"] = [profileImg]
            }
            param["id"] = petId
            param["name"] = tfName.text!
            param["birthday"] = birthday
            param["kind"] = item
            param["weight"] =  Int(Float(weight)!*1000)
            
            if btnPreNeutral.isSelected {
                param["neutral"] = "N"
            }
            else if btnAfeterNeutral.isSelected {
                param["neutral"] = "Y"
            }
            guard let prevent = tfPrevent.text else {
                return
            }
            if prevent == "접종 전"  {
                param["prevention"] = "N"
            }
            else if prevent == "접종 후" {
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
            
            let df = CDateFormatter.init()
            df.dateFormat = "yyyy-MM-dd"
            
            if let date = df.date(from: birthday) {
                let ageInfo = self.getAgeInfo(birthDay: date)
                param["age"] = ageInfo.year
            }
            ApiManager.shared.requestPetInfoModify(param: param) { (response) in
                if let response = response as? [String:Any], let success = response["success"] as? Bool, success == true {
                    self.showToast("동물이 수정되었습니다.")
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    self.showErrorAlertView(response)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorDefault
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = ColorBorder
        }
    }
}

extension AnimalModifyInfoViewController: CameraViewControllerDelegate {
    func didFinishImagePickerAssets(_ assets: [PHAsset]?) {
        guard let assets = assets else {
            return
        }
        guard let asset = assets.first else { return }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: imageScale, height: imageScale), contentMode: .aspectFit, options: PHImageRequestOptions()) { (result, _) in
            guard let result = result else {
                return
            }
            self.profileImg = result
            self.btnProfile.setImage(self.profileImg, for: .normal)
        }
    }
    
    func didFinishImagePicker(origin: UIImage?, crop: UIImage?) {
        self.profileImg = crop
        self.btnProfile.setImage(self.profileImg, for: .normal)
    }
}
