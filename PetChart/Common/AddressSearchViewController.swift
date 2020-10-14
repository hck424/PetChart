//
//  AddressSearchViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/13.
//

import UIKit
import SwiftyJSON

typealias AddressSearchClosure = (_ viewcontroller: UIViewController, _ selData: Any?) ->Void
class AddressSearchViewController: UIViewController {
    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tvTitle: UITextView!
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var svSearch: UIStackView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!
    @IBOutlet weak var bgContainerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var lbEmpty: UILabel!
    
    var arrData: NSMutableArray = NSMutableArray()
    
    var popupTitle:String?
    var completion:AddressSearchClosure?
    var searchKey:String?
    convenience init(title: String?, completion:AddressSearchClosure?) {
        self.init(nibName: "AddressSearchViewController", bundle: nil)
        self.popupTitle = title
        self.completion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvTitle.text = popupTitle
        
        self.tblView.tableFooterView = footerView
        
        bgContainerView.layer.cornerRadius = 20.0
        bgContainerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        tblView.estimatedRowHeight = 60.0
        tblView.rowHeight = UITableView.automaticDimension
        
        self.view.layoutIfNeeded()
        tblView.reloadData {
            self.bottomContainer.constant -= self.bgContainerView.bounds.height
            UIView.animate(withDuration: 0.0) {
                self.btnFullClose.alpha = 0.0
                self.view.layoutIfNeeded()
            } completion: { (finish) in
                self.bottomContainer.constant = 0
                self.heightTblView.constant = UIScreen.main.bounds.height*0.6;
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.btnFullClose.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            }
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
    
    @IBAction func textFieldEdtingChange(_ sender: UITextField) {
        self.searchKey = sender.text
        
        if searchKey?.isEmpty == false {
            NetworkManager.shared.reqeustKakaoAddressSearch(searchKey!) { (response) in
                if let response = response as? Array<Any>, response.count > 0 {
                    self.arrData.removeAllObjects()
                    self.arrData.setArray(response)
                    print(self.arrData)
                }
                
                self.lbEmpty.isHidden = false
                if self.arrData.count > 0 {
                    self.lbEmpty.isHidden = true
                }
                self.tblView.reloadData()
            } failure: { (error) in
                print(String(describing: error))
                self.tblView.reloadData()
            }
        }
        else {
            self.tblView.reloadData()
        }
    }
    
    @IBAction func onClickedButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismissProcess(item: nil)
    }
    
    
    func requestKakakoAddressSearch(_ text: String) {
        
       
    }
    
    func dismissProcess(item: Any?) {
        self.view.layoutIfNeeded()
        self.bottomContainer.constant = -self.bgContainerView.bounds.height
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) {
            self.btnFullClose.alpha = 0
            self.view.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { (finish) in
            self.completion?(self, item)
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
}

extension AddressSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchCell") as? AddressSearchCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("AddressSearchCell", owner: self, options: nil)?.first as? AddressSearchCell
        }
        
        if let item = arrData[indexPath.row] as? [String: Any] {
            cell?.configurationData(item, searchKey)
        }
        return cell!
    }
}
