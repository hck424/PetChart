//
//  AddAnminalKindViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/01.
//

import UIKit
@IBDesignable
class AddAnminalKindViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBInspectable @IBOutlet weak var btnDog: SelectedButton!
    @IBInspectable @IBOutlet weak var btnCat: SelectedButton!
    @IBInspectable @IBOutlet weak var btnOther: SelectedButton!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnSafety: UIButton!
    
    var animal:Animal?
    var selAnimal: AnimalType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBackButton(self, nil, #selector(actionPopViewCtrl))
        CNavigationBar.drawTitle(self, "반려동물 등록", nil)
        
        btnSafety.isHidden = true
        if Utility.isIphoneX() {
            btnSafety.isHidden = false
        }

        if let name = animal?.name {
            let result: String = String(format: "%@는 어떤 반려동물인가요?", name)
            let attr = NSMutableAttributedString.init(string: result, attributes: [.foregroundColor : RGB(136, 136, 136)])
            let nsRange = NSString(string: result).range(of: name, options: String.CompareOptions.caseInsensitive)
            attr.addAttribute(.foregroundColor, value: RGB(23, 133, 239), range: nsRange)
            attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .bold), range: nsRange)
            lbTitle.attributedText = attr
        }
    }
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnDog {
            btnDog.isSelected = true
            btnCat.isSelected = false
            btnOther.isSelected = false
            selAnimal = AnimalType(id: 1, dtype: "puppy", label: "강아지")
        }
        else if sender == btnCat {
            btnDog.isSelected = false
            btnCat.isSelected = true
            btnOther.isSelected = false
            selAnimal = AnimalType(id: 1, dtype: "cat", label: "고양이")
        }
        else if sender == btnOther {
            btnDog.isSelected = false
            btnCat.isSelected = false
            btnOther.isSelected = true
            
            selAnimal = AnimalType(id: 1, dtype: "etc", label: "기타")
        }
        else if sender == btnOk {
            if btnDog.isSelected == false && btnCat.isSelected == false && btnOther.isSelected == false {
                self.view.makeToast("동물 종류를 선택해 주세요", position:.top)
                return
            }
            
            animal?.animalType = selAnimal
            
            let vc = AddAnimalItemSelectViewController.init()
            vc.animal = animal
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
