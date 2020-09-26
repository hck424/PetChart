//
//  TutorialViewController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

    @IBAction func pageControllerValueChange(_ sender: Any) {
    }
    @IBAction func onClickedButtonActions(_ sender: Any) {
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
