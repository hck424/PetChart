//
//  HomeViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit
@IBDesignable
class HomeViewController: BaseViewController {
    @IBOutlet weak var cornerBgView: UIView!
    @IBOutlet weak var btnMypetName: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var svContaner: UIStackView!
    @IBOutlet weak var btnEdting: UIButton!
    

    var hitCount: Int = 0
    var petCount: Int = 0
    var petPopupView: PetSelectPopupView?
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawTitle(self, UIImage(named: "header_logo")!, nil)
        CNavigationBar.drawProfile(self, #selector(onclickedButtonActins(_:)))
    
        cornerBgView.layer.cornerRadius = 20.0
        cornerBgView.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurationUI()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotiNameHitTestView), object: nil)
    }
    
    func configurationUI() {
        
        let hasPet = true
        if hasPet == false {
            let addPetCell = EmptyPetCell.initWithFromNib()
            svContaner.addArrangedSubview(addPetCell)
            addPetCell.didSelectedClouser = ({(selData:Any?, index:Int) -> () in
                let vc = AddAnimalNameViewController.init(nibName: "AddAnimalNameViewController", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: false)
            })
        }
        else {
            for view in svContaner.subviews {
                view.removeFromSuperview()
            }
            
            let dfs = UserDefaults.standard
            var arrType:[PetHealth] = []
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
            if dfs.object(forKey: kMedical) != nil {
                arrType.append(.medical)
            }
            
            for type in arrType {
                let cell = Bundle.main.loadNibNamed("HomeGraphCell", owner: self, options: nil)?.first as! HomeGraphCell
                svContaner.addArrangedSubview(cell)
                cell.configurationData(nil, type: type)
            }
            
            let lbTmp = UILabel()
            lbTmp.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.horizontal)
            lbTmp.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for:.vertical)
            svContaner.addArrangedSubview(lbTmp)
            self.view.layoutIfNeeded()
        }
        
        petCount = 2
        if petCount > 1 {

            let attr = NSMutableAttributedString.init(string: "낭낭이 ")
            let img = UIImage(named: "triangle")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            let attatchment = NSTextAttachment(image: img!)
            attatchment.bounds = CGRect(x: 0, y: 2, width: img!.size.width, height: img!.size.height)
            let attTmp = NSMutableAttributedString.init(attachment: attatchment)
            attTmp.addAttribute(.foregroundColor, value: ColorDefault, range: NSMakeRange(0, attTmp.length))
            attr.append(attTmp)
            btnMypetName.setAttributedTitle(attr, for: .normal)
            
            petPopupView = Bundle.main.loadNibNamed("PetSelectPopupView", owner: self, options: nil)?.first as? PetSelectPopupView
            
            let animal:Animal = Animal()
            animal.name = "푸들이"
            let animal2:Animal = Animal()
            animal2.name = "낑깡이"
            let animal3:Animal = Animal()
            animal3.name = "미미"
            
            var data:[Animal] = [animal, animal2, animal3]
            if let petPopupView = petPopupView {
                self.view.addSubview(petPopupView)
                petPopupView.translatesAutoresizingMaskIntoConstraints = false
                
                petPopupView.topAnchor.constraint(equalTo: cornerBgView.topAnchor, constant: 75).isActive = true
                petPopupView.widthAnchor.constraint(equalToConstant: 160).isActive = true
                petPopupView.centerXAnchor.constraint(equalTo: cornerBgView.centerXAnchor, constant: 60).isActive = true
                
                petPopupView.configurationData(data)
                petPopupView.didClickedClosure = ({(selData:Animal?, index) -> () in
                    print(selData?.name)
                    petPopupView.isHidden = true
                })
                petPopupView.isHidden = true
            }
            
        }
        else {
            btnMypetName.setTitle("낭낭이", for: .normal)
        }
    }
    @objc @IBAction func onclickedButtonActins(_ sender: UIButton) {
        if sender.tag == TAG_NAVI_USER {
//            let vc = AnimalModifyInfoViewController.init(nibName: "AnimalModifyInfoViewController", bundle: nil)
            
//            let vc = MemberInfoModifyViewController.init(nibName: "MemberInfoModifyViewController", bundle: nil)
//            let vc = PetHealthFavoriteEdtingViewController.init()
//            self.navigationController?.pushViewController(vc, animated: false)
//            let picker = CDatePickerView.init(type: .yearMonthDay) { (strDate, date) in
//                print("strDate:\(String(describing: strDate)), date: \(String(describing: date))")
//            }
//            picker?.local = Locale(identifier: "ko_KR")
//            picker?.show()
//            return
            

//            let data = ["포메라니안", "미니어처 핀셔", "파피용", "미니어쳐 닥스훈트", "요크셔테리어", "말티즈", "비숑 프리제", "미니어쳐 슈나우저", "포메라니안", "미니어처 핀셔", "파피용", "미니어쳐 닥스훈트", "요크셔테리어", "말티즈", "비숑 프리제", "미니어쳐 슈나우저", "포메라니안", "미니어처 핀셔", "파피용", "미니어쳐 닥스훈트", "요크셔테리어", "말티즈", "비숑 프리제", "미니어쳐 슈나우저"]
//            let vc = PopupListViewController.init(type: .normal, title: "반려동물을 선택해주세요.", data: data, keys: nil) { (vcs, selData, index) in
//                if let selData = selData {
//                    print(selData)
//                }
//                vcs.dismiss(animated: true, completion: nil)
//            }
//            vc.showSearchBar = true
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: false, completion: nil)
//
//            return
            
//            AlertView.showWithCancelAndOk(title: "로그인 안내", message: "로그인이 필요한 메뉴입니다.\n로그인하시겠습니까") { (index) in
//                if index == 1 {
//                    let vc = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
//                    self.navigationController?.pushViewController(vc, animated: false)
//                }
//            }
        }
        else if sender == btnEdting {
            let vc = PetHealthFavoriteEdtingViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender == btnMypetName {
            if petCount > 1 {
                petPopupView?.isHidden = false
            }
        }
    }
    
    //MAR:: notificationhandler
    @objc func notificationHandler(_ notification: Notification) {
        if notification.name.rawValue == NotiNameHitTestView {
            //두번씩 타서 어쩔수 없이 이렇게 처리함
            if hitCount%2 == 0 {
                if petCount > 1 {
                    if petPopupView?.isHidden == false {
                        petPopupView?.isHidden = true
                    }
                }
            }
            hitCount += 1
        }
    }
}
