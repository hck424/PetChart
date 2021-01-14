//
//  MainTabBarController.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    let homeVc = HomeViewController.init(nibName: "HomeViewController", bundle: nil)
    let chartVc = ChartViewController.init(nibName: "ChartViewController", bundle: nil)
    let communityVc = TalkViewController.init(nibName: "TalkViewController", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNaviCtrl = BaseNavigationController.init(rootViewController: homeVc)
        let chartNaviCtrl = BaseNavigationController.init(rootViewController: chartVc)
        let communityNaviCtrl = BaseNavigationController.init(rootViewController: communityVc)
        self.delegate = self
        self.viewControllers = [homeNaviCtrl, chartNaviCtrl, communityNaviCtrl]

        let imgHome = UIImage(named: "tab_home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgHomeSel = UIImage(named: "tab_home_s")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)

        let imgChart = UIImage(named: "tab_chart")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgChartSel = UIImage(named: "tab_chart_s")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let imgCommunity = UIImage(named: "tab_community")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        let imgCommunitySel = UIImage(named: "tab_community_s")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let item1 = UITabBarItem(title: "홈", image: imgHome, selectedImage: imgHomeSel)
        let item2 = UITabBarItem(title: "차트", image: imgChart, selectedImage: imgChartSel)
        let item3 = UITabBarItem(title: "커뮤니티", image: imgCommunity, selectedImage: imgCommunitySel)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RGB(233, 95, 94)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: RGB(233, 95, 94)], for: .selected)
        
        homeVc.tabBarItem = item1
        chartVc.tabBarItem = item2
        communityVc.tabBarItem = item3
        
//        UITabBar.appearance().tintColor = RGB(233, 95, 94)
        UITabBar.appearance().barTintColor = RGB(255, 255, 255)
        
        self.hidesBottomBarWhenPushed = true
    }
    func changeTabMenuIndex(_ tabIndex:Int, _ subMenuIndex:Int = 0) {
        if tabIndex == 2 && subMenuIndex == 4 {
            communityVc.selCategory = "차트공유"
            communityVc.changeTabMenuWithCategory()
        }
        self.selectedIndex = tabIndex
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("== maintabar viewwillappear")
    }
}
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = self.viewControllers?.firstIndex(of: viewController)
        print("==== will sected tab index: \(String(describing: index))")
        if index == 1 {
            if let hasAnimal = SharedData.objectForKey(key: kHasAnimal) as? String, hasAnimal == "Y" {
                return true
            }
            else {
                AppDelegate.instance()?.window?.rootViewController?.view.makeToast("동물 등록 후 이용가능합니다.")
                return false
            }
        }
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = self.viewControllers?.firstIndex(of: viewController)
        print("==== selected tab index: \(String(describing: index))")
    }
}
