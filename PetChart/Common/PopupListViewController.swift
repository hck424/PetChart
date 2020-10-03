//
//  PopupListViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit
enum PopupListType: Int {
    case normal
}
typealias PopupListClosure = (_ viewcontroller: UIViewController, _ selData: Any?, _ index: Int? ) ->Void

class PopupListViewController: UIViewController {

    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tvTitle: UITextView!
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var svSearch: UIStackView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearCh: UIButton!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!
    @IBOutlet weak var bgContainerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    public var placeHolderString: String?
    public var showSearchBar:Bool = false
    public var enableFullTouchClose = true
    public var showAnimation:Bool = true
    public var animationDuration: TimeInterval = 0.2
    
    var type: PopupListType = .normal
    var originData: Array<Any>?
    var keys: Array<String>?
    var completion: PopupListClosure?
    var data:Array<Any> = []
    var popupTitle: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(type:PopupListType, title: String?, data:Array<Any>, keys:Array<String>?, completion:PopupListClosure?) {
        self.init(nibName: "PopupListViewController", bundle: nil)
        self.popupTitle = title
        self.type = type
        self.originData = data
        self.keys = keys
        self.completion = completion
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let originData = originData {
            self.data.append(contentsOf: originData)
        }
        
        bgContainerView.layer.cornerRadius = 20
        bgContainerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        if let placeHolderString = placeHolderString {
            tfSearch.placeholder = placeHolderString
        }
        else {
            tfSearch.placeholder = "검색어를 입력해주세요."
        }
        
        if showSearchBar == false {
            svSearch.isHidden = true
        }
        
        
        if let popupTitle = popupTitle {
            tvTitle.text = popupTitle
            tvTitle.isHidden = false
        }
        else {
            tvTitle.isHidden = true
        }

        tblView.estimatedRowHeight = 30.0
        tblView.rowHeight = UITableView.automaticDimension
//        tblView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: 20))
        tblView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 34))

        tblView.delegate = self
        tblView.dataSource = self
        
        self.view.layoutIfNeeded()
        tblView.reloadData {
            
            if self.showAnimation {
                self.bottomContainer.constant -= self.bgContainerView.bounds.height
                UIView.animate(withDuration: 0.0) {
                    self.btnFullClose.alpha = 0.0
                    self.view.layoutIfNeeded()
                } completion: { (finish) in
                    self.bottomContainer.constant = 0
                    self.heightTblView.constant = self.tblView.contentSize.height
                    
                    UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut) {
                        self.btnFullClose.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
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
    
    func dismissProcess(item: Any?, index: Int?) {
        if (showAnimation) {
            self.view.layoutIfNeeded()
            self.bottomContainer.constant = -self.bgContainerView.bounds.height
            UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: .curveEaseIn) {
                self.btnFullClose.alpha = 0
                self.view.layoutIfNeeded()
            } completion: { (finish) in
                self.completion?(self, item, index)
            }
        }
        else {
            self.completion?(self, item, index)
        }
    }
    @IBAction func textFieldEdtingChanged(_ textFiled: UITextField) {
        data.removeAll()
        if let text:String = textFiled.text, text.count > 0 {
            guard let originData = originData else {
                return
            }
            let firstObj = originData[0]
            
            if firstObj is String {
                for item in originData {
                    let str = (item as! String).lowercased()
                    if str.contains(text.lowercased()) {
                        data.append(item)
                    }
                }
            }
            else if firstObj is NSAttributedString {
                for item in originData {
                    let str = ((item as! NSAttributedString).string).lowercased()
                    if str.contains(text.lowercased()) {
                        data.append(item)
                    }
                }
            }
            else if firstObj is Dictionary<String, Any> {
                guard let keys = keys else {
                    return
                }
                
                for item in originData  {
                    var result = ""
                    for key in keys {
                        if let item = item as? Dictionary<String, Any> {
                            
                            let value = item[key]
                            if let value = value as? String {
                                result.append(value)
                            }
                            else if let value = value as? Int {
                                result.append(String(format: "%d", value))
                            }
                        }
                    }
                    if result.lowercased().contains(text.lowercased()) {
                        data.append(item)
                    }
                }
            }
        }
        else {
            self.data.append(contentsOf: originData!)
        }
        self.tblView.reloadData()
    }
    
    @IBAction func onClickedButtonActions(_ sender: Any) {
        self.view.endEditing(true)
        if (sender as? NSObject) == btnFullClose
        || (sender as? NSObject) == btnClose {
            self.dismissProcess(item: nil, index: nil)
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

extension PopupListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PopupListCell? = nil
        cell = tableView.dequeueReusableCell(withIdentifier: "PopupListCell") as? PopupListCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PopupListCell", owner: self, options: nil)?.first as? PopupListCell
        }
        
        cell?.ivThumb.isHidden = true
        
        let item = data[indexPath.row]
        if let item = item as? String {
            cell?.lbTitle.text = item
        }
        else if let item = item as? NSAttributedString {
            cell?.lbTitle.attributedText = item
        }
        else if let item = item as? Dictionary<String, Any> {
            if let keys = keys  {
                var result:String = ""
                for key in keys {
                    if let value = item[key] {
                        if let value = value as? String {
                            result.append(value)
                        }
                        else if let value = value as? Int {
                            result.append(String(format: " %d", value))
                        }
                    }
                }
                cell?.lbTitle.text = result
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = data[indexPath.row]
        self.dismissProcess(item: item, index: indexPath.row)
    }
}

extension PopupListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
