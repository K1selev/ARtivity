//
//  TabBar.swift
//  ARtivity
//
//  Created by Сергей Киселев on 28.11.2023.
//

import UIKit

class TabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

       

        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .fullScreen
        self.tabBar.backgroundColor = .white
        let eventVC = ViewController()
//        let eventVCe = UINavigationController(rootViewController: eventVC)

        let mapVC = ViewController()
        let addVC = ViewController()
        let profileVC = ViewController()
        
        let navVC = UINavigationController(rootViewController: eventVC)
//        present(navVC, animated: true)

        let isGuide = UserDefaults.standard.bool(forKey: "isGuide")
        
        eventVC.tabBarItem = UITabBarItem(title: "eventText",
                                          image: UIImage(systemName: "message"),
                                          selectedImage: UIImage(systemName: "message.fill"))
        mapVC.tabBarItem = UITabBarItem(title: "mapText",
                                        image: UIImage(systemName: "map"),
                                        selectedImage: UIImage(systemName: "map.fill"))
        addVC.tabBarItem = UITabBarItem(title: "addText",
                                        image: UIImage(systemName: "plus.circle"),
                                        selectedImage: UIImage(systemName: "plus.circle.fill"))
        profileVC.tabBarItem = UITabBarItem(title: "profileText",
                                            image: UIImage(systemName: "person"),
                                            selectedImage: UIImage(systemName: "person.fill"))
//        if isGuide {
            viewControllers = [navVC, mapVC, addVC, profileVC]
//        } else {
//            viewControllers = [navVC, mapVC, profileVC]
//        }
        selectedIndex = 0
    }
}

