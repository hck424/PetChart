//
//  TalkDetailViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/04.
//

import UIKit
import FSPagerView
protocol TalkDetailViewControllerDelegate {
    func didChangeUserData(data:[String:Any])
}
class TalkDetailViewController: BaseViewController {

    @IBOutlet var footerView: UIView!
    @IBOutlet weak var lbEmpty: UILabel!

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var bottomContainer: NSLayoutConstraint!
    
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var textView: CTextView!
    var headerView:TalkDetailHeaderView?
    
    var heightHeaderView: NSLayoutConstraint?
    var item:[String:Any]? = nil
    var dataDic:[String:Any]? = nil
    var listData:Array<Any> = Array<Any>()
    var delegate:TalkDetailViewControllerDelegate?
    var isChangeUserData:Bool = false
    var saveContentOffset: CGPoint = CGPoint.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, nil, #selector(onClickedButtonActions(_:)))
        CNavigationBar.drawTitle(self, "차트톡 상세", nil)
        
        self.tblView.estimatedRowHeight = 80
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.tableFooterView = footerView
        
        self.requestTalkDetailInfo()
        
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
        if self.isChangeUserData {
            self.delegate?.didChangeUserData(data: self.dataDic!)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headerUpdateLayout()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
        self.headerUpdateLayout()
    }
    
    func headerUpdateLayout() {
        headerView?.translatesAutoresizingMaskIntoConstraints = false

        if let header = self.tblView.tableHeaderView {
            if heightHeaderView != nil {
                header.removeConstraint(heightHeaderView!)
            }
            
            let height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.heightHeaderView = header.heightAnchor.constraint(equalToConstant: height)
            self.heightHeaderView?.priority = UILayoutPriority(rawValue: 900)
            self.heightHeaderView?.isActive = true
            header.widthAnchor.constraint(equalToConstant: self.tblView.frame.size.width).isActive = true
        }
    }
    
    func requestTalkDetailInfo() {
        guard let pId = item?["id"] as? Int else {
            return
        }
        self.listData.removeAll()
        
        ApiManager.shared.requestTalkDetail(pId: pId) { (response) in
            if let response = response as?[String:Any],
               let data = response["data"] as? [String:Any],
               let item = data["item"] as? [String:Any] {
                self.dataDic = item
                if let comments = item["comments"] as? Array<[String:Any]> {
                    self.listData = comments
                }
                if self.listData.isEmpty == true {
                    self.lbEmpty.isHidden = false
                }
                else {
                    self.lbEmpty.isHidden = true
                }
                self.configurationData()
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func configurationData() {
        self.view.layoutIfNeeded()
        self.headerView = Bundle.main.loadNibNamed("TalkDetailHeaderView", owner: self, options: nil)?.first as? TalkDetailHeaderView
        self.tblView.tableHeaderView = headerView!
        self.headerView?.configurationData(self.dataDic)
        
        headerView?.didCloureActions = ({(_ action:HearderActionType) -> () in
            if action == .reload {
                self.headerUpdateLayout()
                self.view.layoutIfNeeded()
                self.tblView.reloadData()
            }
            else if action == .back {
                self.navigationController?.popViewController(animated: true)
            }
            else if action == .like {
                self.reqeustMyLike()
            }
            else if action == .report {
                let title = "관리자에게 게시물 신고하기"
                let msg = "이 게시물의 문제점을 관리자에게 알려주세요.\n신고자의 이름이나 내용은 다른 사람에게 공개되지 않습니다."
                let arrReport = ["스팸/광고글", "폭력물", "혐오발언", "카테고리 부적절"]
                AlertView.showWithCancelAndOk(title: title, message: msg, optionBtnTitles: arrReport) { (index) in

                    let content = arrReport[index]
                    self.requestReport(content: content)
                }
            }
            else if action == .touchIcon {
                guard let icon_url = self.dataDic?["icon_url"] as? String else {
                    return
                }
                self.showPhoto(imgUrls: [icon_url])
            }
            
        })
        
        self.tblView.reloadData {
            self.headerUpdateLayout()
            self.view.layoutIfNeeded()
            self.tblView.layoutIfNeeded()
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == btnWrite {
            let text = textView.text
            textView.text = nil
            self.textViewDidChange(textView)
            
            if let content = text, content.isEmpty == false {
                self.requestWriteComment(content:content)
            }
        }
        else if sender.tag == TAG_NAVI_BACK {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func requestDeleteMyPost(postId:Int) {
        ApiManager.shared.requestDeletePost(postId: postId) { (response) in
            if let response = response as? [String:Any],
               let success = response["success"] as? Bool, success == true {
                self.navigationController?.popViewController(animated: true)
                self.isChangeUserData = true
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func requestWriteComment(content:String) {
        guard let dataDic = dataDic else {
            return
        }
        guard let post_id = dataDic["id"] as? Int else {
            return
        }
        let param: [String:Any] = ["post_id": post_id, "content": content]
        self.saveContentOffset = tblView.contentOffset
        ApiManager.shared.requestWritePostComment(param: param) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any], let comments = data["comments"] as? [String:Any] {
//                self.listData.insert(comments, at: 0)
//                self.tblView.reloadData()
                self.lbEmpty.isHidden = true
                self.requestTalkDetailInfo()
                self.isChangeUserData = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
                    self.tblView.contentOffset = self.saveContentOffset
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func requestReport(content:String) {
        guard let dataDic = dataDic else {
            return
        }
        guard let post_id = dataDic["id"] as? Int else {
            return
        }
        
        let param: [String:Any] = ["post_id": post_id, "content": content]
        ApiManager.shared.requestPostReport(param: param) { (response) in
            if let response = response as? [String:Any], let success = response["success"] as? Bool, success == true {
                self.view.makeToast("게시글 경고 성공하였습니다.")
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func reqeustMyLike() {
        guard var dataDic = dataDic else {
            return
        }
        guard let post_id = dataDic["id"] as? Int else {
            return
        }
        
        var likeState:String = "none"
        if let my_like_state = dataDic["my_like_state"] as? String, my_like_state != "like" {
            likeState = "like"
        }
        var param = [String:Any]()
        param["post_id"] = post_id
        param["dtype"] = likeState
        ApiManager.shared.requestChangeTalkLikeSate(param: param) { (response) in
            if let response = response as?[String:Any], let success = response["success"] as? Bool, let msg = response["msg"] as? String {
//                self.view.makeToast(msg)
                
                if success {
                    dataDic["my_like_state"] = likeState
                    self.dataDic = dataDic
                    self.headerView?.configurationData(self.dataDic)
                    self.tblView.reloadData()
                    self.isChangeUserData = true
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func requestDeleteMyComment(_ selData:[String:Any]) {
        guard let comentId = selData["id"] as? Int else {
            return
        }
        
        ApiManager.shared.requestDeltePostComment(comentId: comentId) { (response) in
            if let response = response as? [String:Any], let success = response["success"] as? Bool, success {
                self.requestTalkDetailInfo()
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    @objc func notificationHandler(_ notification: Notification) {
            
        let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
        let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
 
        if notification.name == UIResponder.keyboardWillShowNotification {
            let bottomSafety: CGFloat = AppDelegate.instance()?.window?.safeAreaInsets.bottom ?? 0
            bottomContainer.constant = heightKeyboard - bottomSafety
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContainer.constant = 0
            UIView.animate(withDuration: TimeInterval(duration)) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension TalkDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TalkDetailCell") as? TalkDetailCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TalkDetailCell", owner: self, options: nil)?.first as? TalkDetailCell
        }
        
        if let item = listData[indexPath.row] as? [String:Any] {
            cell?.configurationData(item)
            cell?.didSelectActionClosure = ({(selData, buttonIndex) -> () in
                if let selData = selData {
                    if buttonIndex == 0 {
                        AlertView.showWithCancelAndOk(title: "댓글 삭제", message: "삭제 하시겠습니까?") { (index) in
                            if index == 1 {
                                self.requestDeleteMyComment(selData)
                            }
                        }
                    }
                    else if buttonIndex == 1 {
                        guard let icon_url = selData["icon_url"] as? String else {
                            return
                        }
                        self.showPhoto(imgUrls: [icon_url])
                    }
                }
            })
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension TalkDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("text: \(text)")
        if text == "\n" {
            var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
            height = height + textView.contentInset.top + textView.contentInset.bottom
            heightTextView.constant = height
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let textView = textView as? CTextView {
            textView.placeholderLabel?.isHidden = !textView.text.isEmpty
        }
        
        var height = textView.sizeThatFits(CGSize.init(width: textView.bounds.width - textView.contentInset.left - textView.contentInset.right, height: CGFloat.infinity)).height
        height = height + textView.contentInset.top + textView.contentInset.bottom
        heightTextView.constant = height
    }
}
