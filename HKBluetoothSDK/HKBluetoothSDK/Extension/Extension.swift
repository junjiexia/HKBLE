//
//  Extension.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/11.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func setNeedLayout(_ views: [UIView]) {
        guard views.count > 0 else {return}
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func autoLayoutTop(_ top: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: related, toItem: other ?? superV, attribute: .top, multiplier: 1, constant: top))
    }
    
    func autoLayoutLeft(_ left: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: related, toItem: other ?? superV, attribute: .left, multiplier: 1, constant: left))
    }
    
    func autoLayoutRight(_ right: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: related, toItem: other ?? superV, attribute: .right, multiplier: 1, constant: right))
    }
    
    func autoLayoutBottom(_ bottom: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: related, toItem: other ?? superV, attribute: .bottom, multiplier: 1, constant: bottom))
    }
    
    func autoLayoutCenter(_ centerX: CGFloat, _ centerY: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: related, toItem: other ?? superV, attribute: .centerX, multiplier: 1, constant: centerX))
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: related, toItem: other ?? superV, attribute: .centerY, multiplier: 1, constant: centerY))
    }
    
    func autoLayoutCenterX(_ centerX: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: related, toItem: other ?? superV, attribute: .centerX, multiplier: 1, constant: centerX))
    }
    
    func autoLayoutCenterY(_ centerY: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView? = nil) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: related, toItem: other ?? superV, attribute: .centerY, multiplier: 1, constant: centerY))
    }
    
    func autoLayoutWidth(_ width: CGFloat, _ related: NSLayoutConstraint.Relation) {
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: related, toItem: nil, attribute: .width, multiplier: 1, constant: width))
    }
    
    func autoLayoutHeight(_ height: CGFloat, _ related: NSLayoutConstraint.Relation) {
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: related, toItem: nil, attribute: .height, multiplier: 1, constant: height))
    }
    
    func autoLayoutTopRelative(_ top: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: related, toItem: other, attribute: .bottom, multiplier: 1, constant: top))
    }
    
    func autoLayoutLeftRelative(_ left: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: related, toItem: other, attribute: .right, multiplier: 1, constant: left))
    }
    
    func autoLayoutRightRelative(_ right: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: related, toItem: other, attribute: .left, multiplier: 1, constant: right))
    }
    
    func autoLayoutBottomRelative(_ bottom: CGFloat, _ related: NSLayoutConstraint.Relation, _ other: UIView) {
        guard let superV = self.superview else {return}
        superV.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: related, toItem: other, attribute: .top, multiplier: 1, constant: bottom))
    }
}

extension String { // mac地址转换
    func macType() -> String { /// 带 ：的大写 Mac 地址
        if !self.contains(":") {
            var arr: [String] = []
            
            let j = 2
            let count = self.count / j + (self.count % j == 0 ? 0 : 1)
            for i in 0..<count {
                let str = self.sub(i * j, j)
                arr.append(str)
            }
            
            return arr.joined(separator: ":").uppercased()
        }
        return self.uppercased()
    }
    
    func sub(_ start: Int, _ count: Int) -> String {
        guard self.count >= start + count else {return ""}
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex =  self.index(self.startIndex, offsetBy: start + count)
        return String(self[startIndex..<endIndex])
    }
    
    func tabType() -> String { /// 不带 ：的十六进制地址
        return removeText(":").lowercased()
    }
    
    func removeText(_ text: String) -> String {
        if self.contains(text) {
            return self.replacingOccurrences(of: text, with: "")
        }
        return self
    }
    
    func getSize(_ font: UIFont) -> CGSize {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
    
    func getHeight(_ font: UIFont, _ width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func getHeight(_ font: UIFont, _ width: CGFloat, _ maxHeight: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height) > maxHeight ? maxHeight : ceil(rect.height)
    }
    
    func getWidth(_ font: UIFont, _ height: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func getWidth(_ font: UIFont, _ height: CGFloat, _ maxWidth: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width) > maxWidth ? maxWidth : ceil(rect.width)
    }
}

extension Date {
    func dateString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // 毫秒级
    static func timeIntervalToDateString(msec interval: TimeInterval, _ format: String) -> String {
        guard interval > 0 else {return ""}
        let timeInterval: TimeInterval = interval / 1000
        let date: Date = Date(timeIntervalSince1970: timeInterval)
        return date.dateString(format)
    }
}

extension Data {
    
    func JSONToStr() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }
    
    /// JSON 解析
    ///
    /// - Returns: JSON 解析后的对象
    func JSONToAny() -> Any {
        do {
            let result = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return result
        } catch  {
            return self
        }
    }
    
}

