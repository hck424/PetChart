//
//  HomeViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
import SwiftyJSON
import FSPagerView

@IBDesignable
class HomeViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var btnMypetName: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var svContaner: UIStackView!
    @IBOutlet weak var btnEdting: UIButton!
    
    var typeIndex: Int = 0
    
    @IBOutlet weak var bannerView: FSPagerView! {
        didSet {
            self.bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.typeIndex = 0
        }
    }
    var bannerList:Array<[String:Any]>?
    var hitCount: Int = 0
    var petCount: Int = 0
    var petPopupView: PetSelectPopupView?
    var arrMyPet: Array<Animal>?
    var selAnimal: Animal?
    let arrGraph:Array<PetHealth> = [.drink, .eat, .weight, .feces, .walk]
    var arrGraphData: [String:Any] = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        CNavigationBar.drawTitle(self, UIImage(named: "header_logo")!, nil)
        CNavigationBar.drawTitle(self, UIImage(named: "icon_logo")!, nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
    
        scrollView.layer.cornerRadius = 20.0
        scrollView.layer.maskedCorners = CACornerMask.init(TL: true, TR: true, BL: false, BR: false)
        
        btnProfile.layer.cornerRadius = btnProfile.bounds.height/2
        btnProfile.layer.borderWidth = 1.5
        btnProfile.layer.borderColor = RGB(222, 222, 222).cgColor
        btnProfile.imageView?.contentMode = .scaleAspectFill
        
        self.requestBannerList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.checkSession { (session) in
            if session == .valid {
                self.requestMyPetList()
            }
            else if session == .empty {
                self.showAlertWithLogin(isExpire: false)
                self.arrMyPet = nil
                self.selAnimal = nil
                self.configurationUI()
            }
            else if session == .expire {
                self.showAlertWithLogin(isExpire: true)
                self.arrMyPet = nil
                self.selAnimal = nil
                self.configurationUI()
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
        if let petPopupView = petPopupView {
            petPopupView.isHidden = true
        }
    }
    
    func requestBannerList() {
        ApiManager.shared.requestBannerList { (response) in
            if let response = response as?[String:Any],
               let data = response["data"] as? [String:Any],
               let bannerList = data["bannerList"] as?Array<[String:Any]> {
                if bannerList.isEmpty == false {
                    self.bannerList = bannerList
                    self.bannerView.automaticSlidingInterval = 3.0
                    self.bannerView.isInfinite = true
                    self.bannerView.decelerationDistance = FSPagerView.automaticDistance
                    self.bannerView.delegate = self
                    self.bannerView.dataSource = self
                    self.bannerView.reloadData()
                }
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func requestMyPetList() {
        
        ApiManager.shared.requestMyPetList { (response) in
            if let response = response as?[String:Any],
               let data = response["data"] as? [String:Any],
               let pets = data["pets"] as? Array<[String:Any]> {
                if pets.isEmpty == false {
                    
                    SharedData.setObjectForKey(key: kHasAnimal, value: "Y")
                    
                    self.arrMyPet = Array<Animal>()
                    for pet in pets {
                        let animal:Animal = Animal.init(JSON: pet)!
                        self.arrMyPet?.append(animal)
                    }
                    
                    if let arrMyPet = self.arrMyPet, arrMyPet.isEmpty == false {
                        
                        if let saveMainPetId = UserDefaults.standard.object(forKey: kMainShowPetId) as? Int  {
                            for animal in arrMyPet {
                                if animal.id! == saveMainPetId {
                                    self.selAnimal = animal
                                    break
                                }
                            }
                        }
                        //저장된 펫 아이디가 못찾았다면 메인펫 설정된 놈 중 첫번째거
                        if self.selAnimal == nil {
                            self.selAnimal = arrMyPet.first
                        }
                    }
                }
                else {
                    self.arrMyPet = nil
                    SharedData.removeObjectForKey(key: kHasAnimal)
                }
                self.configurationUI()
            }
            else {
                self.arrMyPet = nil
                self.configurationUI()
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }

    //FIXME:: UI Data mapping
    func configurationUI() {
        
        for view in svContaner.subviews {
            view.removeFromSuperview()
        }
        ///등록된 펫이 없다면
        guard let arrMyPet = arrMyPet, arrMyPet.isEmpty == false else {
            btnEdting.isHidden = true
            btnMypetName.isHidden = true
            btnProfile.setImage(UIImage(named: "btn_imgadd"), for: .normal)
            btnProfile.layer.borderColor = RGB(222, 222, 222).cgColor
            let emptyPetCell = EmptyPetCell.initWithFromNib()
            svContaner.addArrangedSubview(emptyPetCell)
            emptyPetCell.didSelectedClosure = ({(selData:Any?, index:Int) -> () in
                self.checkSession { (type) in
                    if type == .valid {
                        let vc = AddAnimalNameViewController.init(nibName: "AddAnimalNameViewController", bundle: nil)
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                    else if type == .expire {
                        self.showAlertWithLogin(isExpire: true)
                    }
                    else {
                        self.showAlertWithLogin(isExpire: false)
                    }
                }
                
            })
            return
        }
        
        btnEdting.isHidden = false
        btnMypetName.isHidden = false
        
        var arrMainShow = [Animal]()
        for animal in arrMyPet {
            if let is_main = animal.is_main {
                if is_main == "Y" {
                    arrMainShow.append(animal)
                }
            }
        }
        
        if let selAnimal = selAnimal {
            UserDefaults.standard.setValue(selAnimal.petName, forKey: kMainShowPetName)
            UserDefaults.standard.setValue(selAnimal.id, forKey: kMainShowPetId)
            UserDefaults.standard.synchronize()
            
            btnMypetName.isHidden = false
            if let images = selAnimal.images,
               let imageInfo = images.first,
               let original = imageInfo.original {
                
                ImageCache.downLoadImg(url: original, userInfo: nil) { (image, userinfo) in
                    if let image = image {
                        self.btnProfile.setImage(image, for: .normal)
                        self.btnProfile.layer.borderColor = ColorDefault.cgColor
                    }
                }
            }
            
            if let lbName: UILabel = btnMypetName.viewWithTag(100) as? UILabel, let petName = selAnimal.petName {
                lbName.text = petName
            }
            if let lbKind: UILabel = btnMypetName.viewWithTag(101) as? UILabel {
                var tmpStr = ""
                if let kind = selAnimal.kind {
                    tmpStr.append(" \(kind)")
                }
                else if let size = selAnimal.size {
                    tmpStr.append(" \(size)")
                }
                if let sex = selAnimal.sex, sex == "M" {
                    tmpStr.append(" / ♂︎")
                }
                else {
                    tmpStr.append(" / ♀︎")
                }
                lbKind.text = tmpStr
            }
            
            
            if let ivArrow: UIImageView = btnMypetName.viewWithTag(102) as? UIImageView {
                if arrMainShow.isEmpty == false {
                    ivArrow.isHidden = false
                }
                else {
                    ivArrow.isHidden = true
                }
            }
            self.requestTodayMainData()
        }
        else {
            btnMypetName.isHidden = true
        }
        
        if arrMainShow.isEmpty == false {
            if let petPopupView = petPopupView {
                petPopupView.removeFromSuperview()
            }
            self.petPopupView = Bundle.main.loadNibNamed("PetSelectPopupView", owner: self, options: nil)?.first as? PetSelectPopupView
            
            self.view.addSubview(petPopupView!)
            petPopupView?.translatesAutoresizingMaskIntoConstraints = false
            petPopupView?.topAnchor.constraint(equalTo: cornerBgView.topAnchor, constant: 75).isActive = true
            petPopupView?.widthAnchor.constraint(equalToConstant: 160).isActive = true
            petPopupView?.centerXAnchor.constraint(equalTo: cornerBgView.centerXAnchor, constant: 60).isActive = true
            petPopupView?.configurationData(arrMainShow)
            petPopupView?.didClickedClosure = ({(selData:Animal?, index) -> () in
                if let selData = selData {
                    self.selAnimal = selData
                    self.configurationUI()
                    print(selData.petName as Any)
                }
                self.petPopupView?.isHidden = true
            })
            petPopupView?.isHidden = true
        }
        else {
            if let petPopupView = petPopupView {
                petPopupView.removeFromSuperview()
            }
        }
    }
    
    func requestTodayMainData() {
        guard let selAnimal = self.selAnimal else { return }
        
        ApiManager.shared.requestTodayMainData(petId: selAnimal.id!) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any], data.isEmpty == false {
                self.arrGraphData = data
                self.configurationGraphData()
            }
            else {
                self.showErrorAlertView(response)
            }
        } failure: { (error) in
            self.showErrorAlertView(error)
        }
    }
    
    func configurationGraphData() {
        let dfs = UserDefaults.standard
        var arrType: Array<PetHealth> = Array<PetHealth>()
        
        if dfs.object(forKey: kDrink) != nil {
            arrType.append(.drink)
        }
        if dfs.object(forKey: kEat) != nil {
            arrType.append(.eat)
        }
        if dfs.object(forKey: kWeight) != nil {
            arrType.append(.weight)
        }
        if dfs.object(forKey: kFeces) != nil {
            arrType.append(.feces)
        }
        if dfs.object(forKey: kWalk) != nil {
            arrType.append(.walk)
        }
//        if dfs.object(forKey: kMedical) != nil {
//            arrType.append(.medical)
//        }
        
        //그래프 노출 다 off 했을시 다 보여준다.
        if arrType.isEmpty == false {
            for type in arrType {
                let cell = Bundle.main.loadNibNamed("HomeGraphCell", owner: self, options: nil)?.first as! HomeGraphCell
                svContaner.addArrangedSubview(cell)
                var item: [String:Any]?
                if type == .drink {
                    item = arrGraphData["drink"] as? [String : Any]
                }
                else if type == .eat {
                    item = arrGraphData["eat"] as? [String : Any]
                }
                else if type == .weight {
                    item = arrGraphData["weight"] as? [String : Any]
                }
                else if type == .feces {
                    item = arrGraphData["catharsis"] as? [String : Any]
                }
                else if type == .walk {
                    item = arrGraphData["walk"] as? [String : Any]
                }
                
                cell.configurationData(item, type: type)
            }
        }
        
        let lbTmp = UILabel()
        lbTmp.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.horizontal)
        lbTmp.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.vertical)
        svContaner.addArrangedSubview(lbTmp)
        self.view.layoutIfNeeded()
    }
    
    //FIXME:: custom btn actions
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {

            self.checkSession { (session) in
                if session == .valid {
                    self.gotoMyinfoVc()
                }
                else if session == .expire {
                    self.showAlertWithLogin(isExpire: true)
                }
                else {
                    self.showAlertWithLogin(isExpire: false)
                }
            }
        }
        else if sender == btnEdting {
            let vc = PetHealthFavoriteEdtingViewController.init()
            vc.data = arrGraph
            vc.catergory = .graphHome
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnMypetName {
            petPopupView?.isHidden = false
        }
        else if sender == btnProfile {
            if let selAnimal = selAnimal, let images = selAnimal.images {
                var imgUrls:[String] = [String]()
                for imgInfo in images {
                    if let original = imgInfo.original {
                        imgUrls.append(original)
                    }
                }
                
                self.showPhoto(imgUrls: imgUrls)
            }
        }
    }
    
    //MAR:: notificationhandler
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name.rawValue == NotiNameHitTestView {
            //두번씩 타서 어쩔수 없이 이렇게 처리함
            if hitCount%2 == 0 {
                if petPopupView?.isHidden == false {
                    petPopupView?.isHidden = true
                }
            }
            hitCount += 1
        }
    }
}

extension HomeViewController : FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let bannerList = bannerList {
            return bannerList.count
        }
        return 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if let imageview = cell.imageView, let item = bannerList?[index] {
//                   "title": "test",
//                   "link": "https://www.naver.com",
//                   "img_url": "https://jayutest.best:5001/images/banner/02.jpeg"
            if let imgUrl = item["img_url"] as? String {
                imageview.setImageCache(url: imgUrl, placeholderImgName: nil)
            }
            imageview.contentMode = .scaleAspectFill
            imageview.clipsToBounds = true
            
//            if let title = item["title"] as? String {
//                cell.textLabel?.text = title
//                cell.textLabel?.textAlignment = .right
//            }
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        
        if let item = bannerList?[index], let link = item["link"] as? String {
            AppDelegate.instance()?.openUrl(link, completion: nil)
        }
    }
    
}
