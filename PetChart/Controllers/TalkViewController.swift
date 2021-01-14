//
//  TalkViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit


class TalkViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tfSearch: CTextField!
    @IBOutlet var arrBtnPet: [UIButton]!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnWrite: UIButton!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var searchBgView: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet var accessoryView: UIToolbar!
    @IBOutlet weak var keyBoardDown: UIBarButtonItem!
    @IBOutlet weak var btnFooterMore: UIButton!
    @IBOutlet var footerView: UIView!
    
    
    let TAG_UNDER_LINE: Int = 1234567
    var limit:Int = 10
    var page = 1
    var isEnd:Bool = false
    var selCategory:String = ""
    var searchTxt: String? = nil
    
    var arrData:Array<[String:Any]> = Array<[String:Any]>()
    var isRequest = false
    var selectedData: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CNavigationBar.drawTitle(self, "차트톡", nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
        
        tfSearch.delegate = self
        tfSearch.inputAccessoryView = accessoryView
        searchBgView.layer.cornerRadius = searchBgView.bounds.height/2
        
        cornerBgView.layer.cornerRadius = 20
        cornerBgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        arrBtnPet = arrBtnPet.sorted(by: { (btn1, btn2) -> Bool in
            return btn1.tag < btn2.tag
        })
        
        for btn in arrBtnPet {
            btn.addTarget(self, action: #selector(onclickedButtonActins(_:)), for: .touchUpInside)
        }

        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.bounds.width, height: 8))
        tblView.tableHeaderView = headerView
        tblView.estimatedRowHeight = 100
        tblView.rowHeight = UITableView.automaticDimension
        
        tblView.tableFooterView = footerView
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkSession { (type) in
            if type == .valid {
                let index = self.getSelectedCategoryIndex()
                let btn = self.arrBtnPet[index]
                btn.sendActions(for: .touchUpInside)
            }
            else if type == .expire {
                self.showAlertWithLogin(isExpire: true)
                self.arrData.removeAll()
                self.tblView.isHidden = true
            }
            else {
                self.showAlertWithLogin(isExpire: false)
                self.arrData.removeAll()
                self.tblView.isHidden = true
            }
        }
    }
    
    func getSelectedCategoryIndex() ->Int {
        if selCategory == "강아지" {
            return 1
        }
        else if selCategory == "고양이" {
            return 2
        }
        else if selCategory == "기타" {
            return 3
        }
        else if selCategory == "차트공유" {
            return 4
        }
        else {
            return 0
        }
    }
    func removeUnderline(_ sender: UIButton) {
        if let view = sender.viewWithTag(TAG_UNDER_LINE) {
            view.removeFromSuperview()
        }
        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .regular)
        sender.setTitleColor(RGB(145, 145, 145), for: .normal)
    }
    
    func addUnderLine(_ sender: UIButton) {
        let width = sender.bounds.width * 0.6
        let underline = UIView.init(frame: CGRect(x: (sender.bounds.width - width)/2, y: sender.bounds.height/2 + 3, width: width, height: 8))
        underline.backgroundColor = RGBA(233, 95, 94, 0.5)
        underline.tag = TAG_UNDER_LINE
        sender.addSubview(underline)

        sender.titleLabel?.font = UIFont.systemFont(ofSize: sender.titleLabel?.font.pointSize ?? 15, weight: .bold)
        sender.setTitleColor(UIColor.black, for: .normal)
    }
    
    func dataRest() {
        page = 1
        isEnd = false
        arrData.removeAll()
        self.requestComunityList()
    }
    func addData() {
        self.page += 1
        self.requestComunityList()
    }
    
    func requestComunityList() {
        if isEnd == true {
            return
        }
        
        var param:[String:Any] = [String:Any]()
        if selCategory.isEmpty == false {
            param["tag"] = selCategory
        }
        param["page"] = page
        param["limit"] = limit
        if let search = searchTxt, search.isEmpty == false {
            param["search"] = search
        }
        
        ApiManager.shared.requestTalkList(param: param) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any] {
                self.isRequest = false
                
                if let posts = data["posts"] as? Array<[String:Any]>, posts.isEmpty == false {
                    if self.page == 1 {
                        self.arrData = posts
                    }
                    else {
                        self.arrData.append(contentsOf: posts)
                    }
                }
                
                if let isEnd = data["isEnd"] as? Bool {
                    self.isEnd = isEnd
                }
                if let limit = data["limit"] as? Int {
                    self.limit = limit
                }
                if let page = data["page"] as? Int {
                    self.page = page
                }
                
                if self.arrData.isEmpty == true {
                    self.tblView.isHidden = true
                } else {
                    self.tblView.isHidden = false
                }
                self.tblView.reloadData()
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    func gotoTalkWriteVc(_ snapshot:UIImage) {
        let vc = TalkWriteViewController.init()
        vc.delegate = self
        if let img = snapshot.resized(toWidth: imageScale) {
            vc.snapshot = img
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func textFieldEdtingValueChanged(_ sender: UITextField) {
        
        self.searchTxt = sender.text
    }
    
    @IBAction func onClickedKeyboardDown(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        self.checkSession { (session) in
            if session == .valid {
                if sender.tag == TAG_NAVI_USER {
                    self.gotoMyinfoVc()
                }
                else if sender == self.btnWrite {
                    let vc = TalkWriteViewController.init()
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: false)
                }
                else if sender == self.btnSearch {
                    self.view.endEditing(true)
                    self.dataRest()
                }
                else if self.arrBtnPet.contains(sender) {
                    for btn in self.arrBtnPet {
                        self.removeUnderline(btn)
                    }
                    self.addUnderLine(sender)
                    self.searchTxt = nil
                    self.tfSearch.text = nil
                    if sender.tag == 0 {
                        self.selCategory = ""
                    }
                    else if sender.tag == 1 {
                        self.selCategory = "강아지"
                    }
                    else if sender.tag == 2 {
                        self.selCategory = "고양이"
                    }
                    else if sender.tag == 3 {
                        self.selCategory = "기타"
                    }
                    else if sender.tag == 4 {
                        self.selCategory = "차트공유"
                    }
                    self.dataRest()
                }
            }
            else if session == .expire {
                self.showAlertWithLogin(isExpire: true)
            }
            else {
                self.showAlertWithLogin(isExpire: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TalkCell") as? TalkCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TalkCell", owner: self, options: nil)?.first as? TalkCell
        }
        if indexPath.row < arrData.count {
            let item = arrData[indexPath.row]
            cell?.configurationData(item)
        }
        cell?.didClickedActionClosure = { (selData:[String:Any]?, buttonAction:Int)->() in
            if let selData = selData {
                self.selectedData = selData
                if buttonAction == 0 {
                    self.reqeustMyLike()
                }
                else if buttonAction == 1 {
                    guard let images = selData["images"] as? Array<[String:Any]> else {
                        return
                    }
                    var imgUrls:[String] = [String]()
                    for item in images {
                        if let original = item["original"] as? String {
                            imgUrls.append(original)
                        }
                    }
                    self.showPhoto(imgUrls: imgUrls)
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = arrData[indexPath.row]
        let vc = TalkDetailViewController.init()
        vc.delegate = self
        vc.item = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reqeustMyLike() {
        guard let selectedData = selectedData else {
            return
        }
        guard let post_id = selectedData["id"] as? Int else {
            return
        }
        
        var likeState:String = "none"
        if let my_like_state = selectedData["my_like_state"] as? String, my_like_state != "like" {
            likeState = "like"
        }
        var param = [String:Any]()
        param["post_id"] = post_id
        param["dtype"] = likeState
        ApiManager.shared.requestChangeTalkLikeSate(param: param) { (response) in
            if let response = response as?[String:Any], let success = response["success"] as? Bool, let msg = response["msg"] as? String {
                self.view.makeToast(msg)
                
                if success {
                    var index:Int = 0
                    var findItem:[String:Any] = [String:Any]()
                    
                    for item in self.arrData {
                        let id = item["id"] as! Int
                        if id == post_id {
                            findItem = item
                            findItem["my_like_state"] = likeState
                            break
                        }
                        index += 1
                    }
                    self.arrData[index] = findItem
                    self.tblView.reloadData()
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func changeTabMenuWithCategory() {
        let index = self.getSelectedCategoryIndex()
        guard let arrBtnPet = arrBtnPet, let btn = arrBtnPet[index] as? UIButton else {
            return
        }
        btn.sendActions(for: .touchUpInside)
    }
}

extension TalkViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocityY = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
        let contentSizeH = ceil(scrollView.contentSize.height * 100)/100
        let contentOffsetY = ceil((scrollView.contentOffset.y + scrollView.bounds.height) * 100)/100
        
        //add data
        if velocityY < 0 && contentOffsetY > contentSizeH && isRequest == false {
            isRequest = true
            self.addData()
        }
    }
}

extension TalkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == false {
            self.searchTxt = textField.text!
        }
        else {
            self.searchTxt = nil
        }
        
        self.dataRest()
        self.view.endEditing(true)
        return true
    }
}

extension TalkViewController: TalkWriteViewControllerDelegate {
    func didfinishWrite(category: String, data: [String : Any]?) {
        self.selCategory = category
//        self.changeTabMenuWithCategory()
    }
}
extension TalkViewController: TalkDetailViewControllerDelegate {
    func didChangeUserData(data: [String : Any]) {
//        guard let id = data["id"] as? Int, let my_like_state = data["my_like_state"] as? String else {
//            return
//        }
//        var i = 0
//        for var item in arrData {
//            guard let postId = item["id"] as? Int else {
//                return
//            }
//
//            if postId == id {
//                guard var oldLikeState = item["my_like_state"] as? String else {
//                    return
//                }
//
//                oldLikeState = my_like_state
//                item["my_like_state"] = oldLikeState
//                arrData[i] = item
//                break
//            }
//            i += 1
//        }
//        self.tblView.reloadData()
    }
}
