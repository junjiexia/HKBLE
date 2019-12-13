//
//  Helper.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/12.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    class func keywindows() -> UIWindow? {
        var window:UIWindow? = nil
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                    break
                }
            }
            if let win = window {
                return win
            }else {
                let sceneSet = UIApplication.shared.connectedScenes as? Set<UIWindowScene>
                return sceneSet?.first?.windows.first
            }
        }else{
            return UIApplication.shared.keyWindow
        }
    }
}

final class FindHelper {
    
    static let share = FindHelper()
    
    var currentViewCotroller: UIViewController? {
        
        var result: UIViewController? = nil
        var window: UIWindow
        
        guard let _window = Helper.keywindows() else {
            return result
        }
        window = _window
        
        if window.windowLevel != UIWindow.Level.normal {
            guard let _tmpWin =  UIApplication.shared.windows
                .filter({ $0.windowLevel == UIWindow.Level.normal })
                .first else {
                    return result
            }
            window = _tmpWin
        }
        
        var nextResponder: UIResponder? = nil
        let appRootVC = window.rootViewController
        
        // 如果是present上来的appRootVC.presentedViewController 不为nil
        if let presentedVC = appRootVC?.presentedViewController {
            nextResponder = presentedVC
        }else {
            if #available(iOS 13.0, *) {
                nextResponder = appRootVC
            }else {
                let frontView = window.subviews[0]
                nextResponder = frontView.next
            }
        }
        
        if let tabbar = nextResponder as? UITabBarController {
            if let nav = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                result = nav.children.last
            }
        } else if let nav = nextResponder as? UINavigationController {
            result = nav.children.last
        } else {
            result = nextResponder as? UIViewController
        }
        
        return result
    }
}
