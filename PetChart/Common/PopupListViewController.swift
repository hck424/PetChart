//
//  PopupListViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/02.
//

import UIKit
enum PopupListType: Int {
    case normal
    case wifi
}
typealias PopupListClosure = (_ viewcontroller: UIViewController, _ selData: Any?, _ index: Int? ) ->Void

class PopupListViewController: UIViewController {

    @IBOutlet weak var btnFullClose: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svTitle: UIStackView!
    @IBOutlet weak var svContainer: UIStackView!
    @IBOutlet weak var svSearch: UIStackView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearCh: UIButton!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!
    @IBOutlet weak var bgContainerView: UIView!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    @IBOutlet weak var heightTitle: NSLayoutConstraint!
    @IBOutlet weak var widthContainerView: NSLayoutConstraint! 
    
    public var placeHolderString: String?
    public var showSearchBar:Bool = false
    public var enableFullTouchClose = true
    public var edgeTitle = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    public var edgeSearchBar = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    public var edgeContainer = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    public var widthRate:CGFloat = 0.8
    
    let mininumBottom: CGFloat = 80
    var type: PopupListType = .normal
    var originData: Array<Any>?
    var keys: Array<String>?
    var completion: PopupListClosure?
    var data:Array<Any> = []
    var popupTitle: String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
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
        overrideUserInterfaceStyle = .light
        if let originData = originData {
            self.data.append(contentsOf: originData)
        }
        
        bgContainerView.layer.cornerRadius = 20
        bgContainerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: true, BR: true)
        
        svTitle.isLayoutMarginsRelativeArrangement = true
        svTitle.layoutMargins = edgeTitle
        
        svSearch.isLayoutMarginsRelativeArrangement = true
        svSearch.layoutMargins = edgeSearchBar
        
        svContainer.isLayoutMarginsRelativeArrangement = true
        svContainer.layoutMargins = edgeContainer
        tblView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        if let placeHolderString = placeHolderString {
            tfSearch.placeholder = placeHolderString
        }
        else {
            tfSearch.placeholder = "검색어를 입력해주세요."
        }
        
        if showSearchBar == false {
            svSearch.isHidden = true
        }
        
        widthContainerView.constant = UIScreen.main.bounds.width * widthRate
        
        if let popupTitle = popupTitle {
            svTitle.isHidden = false
            lbTitle.text = popupTitle
            
            let height = lbTitle.sizeThatFits(CGSize(width: lbTitle.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            heightTitle.constant = height
        }
        else {
            svTitle.isHidden = true
        }

        tblView.estimatedRowHeight = 30.0
        tblView.rowHeight = UITableView.automaticDimension
//        tblView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: 20))
        tblView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: tblView.frame.size.width, height: 1))

        tblView.delegate = self
        tblView.dataSource = self
        
        self.view.layoutIfNeeded()
        tblView.reloadData {
            self.heightTblView.constant = self.tblView.contentSize.height
            self.view.layoutIfNeeded()
            self.btnFullClose.backgroundColor = UIColor.clear
            self.bgContainerView.alpha = 0.0
            self.bgContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                self.btnFullClose.backgroundColor = RGBA(0, 0, 0, 0.2)
                self.bgContainerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.bgContainerView.alpha = 1.0
            } completion: { (finish) in
                self.heightTblView.constant = self.tblView.contentSize.height
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
    func reloadData(_ data:[Any]?) {
        
        if let data = data {
            self.originData?.removeAll()
            self.data.removeAll()
            self.originData = data
            self.data = data
        }
        tblView.reloadData {
            self.heightTblView.constant = self.tblView.contentSize.height
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                self.view.layoutIfNeeded()
            } completion: { (finish) in
                self.heightTblView.constant = self.tblView.contentSize.height
            }
        }
    }
    func dismissProcess(item: Any?, index: Int?) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.btnFullClose.backgroundColor = UIColor.clear
            self.bgContainerView.alpha = 0.0
            self.bgContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { (finish) in
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
        if (sender as? NSObject) == btnFullClose {
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
            bottomContainer.constant = mininumBottom
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
        else if let item = item as? WifiInfo {
            cell?.ivThumb.isHidden = true
            cell?.lbTitle.text = item.ssid
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
