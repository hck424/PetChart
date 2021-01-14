//
//  AddAnimalItemSelectViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit

@IBDesignable class AddAnimalItemSelectViewController: BaseViewController {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnSafety: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnItemKnow: UIButton!
    @IBOutlet weak var btnItemUnknow: UIButton!
    @IBInspectable @IBOutlet weak var tfItem: CTextField!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnSmall: SelectedButton!
    @IBOutlet weak var btnMiddle: SelectedButton!
    @IBOutlet weak var btnLarge: SelectedButton!
    
    @IBOutlet weak var svKnow: UIStackView!
    @IBOutlet weak var svUnknow: UIStackView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var btnKeyboardDown: UIBarButtonItem!
    @IBOutlet var accessoryView: UIToolbar!
    
    var animal: Animal?
    var images:Array<UIImage>?
    var arrOriginKind:Array<String> = Array<String>()
    var arrKind:Array<String> = Array<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }
    
        self.requestKindList()
        btnItemKnow.sendActions(for: .touchUpInside)
        self.tblView.isHidden = true
        self.tblView.tableFooterView = UIView.init()
        tfItem.inputAccessoryView = accessoryView
        
        if let name = animal?.petName {
            let result: String = String(format: "%@의 품종을 알려주세요.", name)
            let attr = NSMutableAttributedString.init(string: result, attributes: [.foregroundColor : RGB(136, 136, 136)])
            let nsRange = NSString(string: result).range(of: name, options: String.CompareOptions.caseInsensitive)
            attr.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange)
            lbTitle.attributedText = attr
        }
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

    func requestKindList() {
        guard let dtype = animal?.dtype else {
            return
        }
        
        ApiManager.shared.requestAnimalKinds(dtype: dtype) { (response) in
            if let response = response as? [String:Any], let success = response["success"] as? Bool , let list = response["list"] as? Array<String>  {
                if success && list.isEmpty == false {
                    self.arrOriginKind = list
                    self.arrKind = self.arrOriginKind
                }
            }
        } failure: { (error) in
            
        }

    }
    
    @IBAction func textFieldEdtingChanged(_ sender: UITextField) {
        guard let text = sender.text, text.isEmpty == false else {
            self.arrKind = self.arrOriginKind
            self.tblView.isHidden = true
            return
        }
        
        self.arrKind.removeAll()
        for item in arrOriginKind {
            if item.contains(text) {
                arrKind.append(item)
            }
        }
        
        if self.arrKind.count > 0 {
            self.tblView.isHidden = false
            self.tblView.reloadData()
        }
        else {
            self.tblView.isHidden = true
        }
        
    }
    @IBAction func onClickedKeyboardDown(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickedButtonActions(_ sender: CButton) {
        self.view.endEditing(true)
        if sender == btnItemKnow {
            btnItemUnknow.isSelected = false
            sender.isSelected = true
            
            svKnow.isHidden = false
            svUnknow.isHidden = true
            tfItem.text = nil
        }
        else if sender == btnItemUnknow {
            btnItemKnow.isSelected = false
            sender.isSelected = true
            tfItem.text = nil
            tblView.isHidden = true
            
            svKnow.isHidden = true
            svUnknow.isHidden = false
            
            btnSmall.isSelected = false
            btnMiddle.isSelected = false
            btnLarge.isSelected = false
        }
        else if sender == btnSmall {
            btnSmall.isSelected = true
            btnMiddle.isSelected = false
            btnLarge.isSelected = false
        }
        else if sender == btnMiddle {
            btnSmall.isSelected = false
            btnMiddle.isSelected = true
            btnLarge.isSelected = false
        }
        else if sender == btnLarge {
            btnSmall.isSelected = false
            btnMiddle.isSelected = false
            btnLarge.isSelected = true
        }
        else if sender == btnOk {
            if btnItemKnow.isSelected {
                guard let item = tfItem.text, item.isEmpty == false else {
                    self.showToast("품종 선택해주세요.")
                    return
                }
                animal?.kind = item
                animal?.size = nil
            }
            else if btnItemUnknow.isSelected {
                animal?.kind = nil
                if btnSmall.isSelected {
                    animal?.size = "S"
                }
                else if btnMiddle.isSelected {
                    animal?.size = "M"
                }
                else if btnLarge.isSelected {
                    animal?.size = "M"
                }
                
                guard let _ = animal?.size else {
                    self.showToast("크기를 선택해주세요.")
                    return
                }
            }
            
            let vc = AddAnimalBirthDayViewController.init(nibName: "AddAnimalBirthDayViewController", bundle: nil)
            vc.animal = animal
            vc.images = images
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
        if notification.name == UIResponder.keyboardWillShowNotification {
            bottomContainer.constant = heightKeyboard - (AppDelegate.instance()?.window?.safeAreaInsets.bottom)! - self.btnOk.bounds.height
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

extension AddAnimalItemSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrKind.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchAnimalKindCellTableViewCell") as? SearchAnimalKindCellTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("SearchAnimalKindCellTableViewCell", owner: self, options: nil)?.first as? SearchAnimalKindCellTableViewCell
        }
        
        let item = arrKind[indexPath.row]
        cell?.lbTitle.text = item
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
        guard let item = arrKind[indexPath.row] as? String else {
            return
        }
        self.tfItem.text = item
        self.tblView.isHidden = true
    }
}

extension AddAnimalItemSelectViewController: UITextFieldDelegate {
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
