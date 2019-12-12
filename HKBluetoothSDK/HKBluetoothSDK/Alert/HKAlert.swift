//
//  HKAlert.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/11.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import Foundation
import UIKit

class HKAlert {
    class func show(alert viewController: UIViewController?,
                    _ title: String?,
                    _ message: String?,
                    sureCallback: (() -> Void)?) {
        let alert_vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            sureCallback?()
        }
        
        alert_vc.addAction(cancel)
        alert_vc.addAction(ok)
        
        if let vc = viewController {
            vc.present(alert_vc, animated: true, completion: nil)
        }else {
            FindHelper.share.currentViewCotroller?.present(alert_vc, animated: true, completion: nil)
        }
    }
    
    class func show(prompt viewController: UIViewController?,
                    _ title: String?,
                    _ message: String?) {
        let alert_vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let vc = viewController {
            vc.present(alert_vc, animated: true, completion: nil)
        }else {
            FindHelper.share.currentViewCotroller?.present(alert_vc, animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert_vc.dismiss(animated: true, completion: nil)
        }
    }
}


