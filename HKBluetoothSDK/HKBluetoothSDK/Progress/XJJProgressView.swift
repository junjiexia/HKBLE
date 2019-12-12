//
//  XJJProgressView.swift
//  EPalmPatrol
//
//  Created by Levy on 2019/8/22.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import UIKit

class XJJProgress {
    static var progressView: XJJProgressView?
    
    class func start(_ title: String, _ message: String, _ complatedBlcok: (() -> Void)?) {
        progressView = XJJProgressView()
        progressView?.frame = UIScreen.main.bounds
        progressView?.titleText = title
        progressView?.messageText = message
        progressView?.progress = 0
        
        Helper.keywindows()?.addSubview(progressView!)
        
        progressView?.complateBlock = {
            complatedBlcok?()
        }
    }
    
    class func update(_ progress: Float) {
        progressView?.progress = progress
    }
    
    class func end() {
        progressView?.removeFromSuperview()
        progressView = nil
    }
    
}

class XJJProgressView: UIView {
    var complateBlock: (() -> Void)?
    
    var titleText: String? {
        didSet {
            guard let text = titleText else {return}
            self.titleLabel.text = text
        }
    }
    
    var messageText: String? {
        didSet {
            guard let text = messageText else {return}
            self.messageLabel.text = text
        }
    }
    
    // 0 ~ 100
    var progress: Float? {
        didSet {
            guard let p = progress else {return}
            self.progressView.progress = p / 100
            self.remaidLabel.text = String(format: "%.0f%%", p)
            
            if p >= 100 {
                self.complateBlock?()
                self.removeFromSuperview()
                XJJProgress.progressView = nil
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setSubviewsLayout()
    }
    
    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!
    private var progressView: UIProgressView!
    private var remaidLabel: UILabel!
    
    private func initUI() {
        self.contentView = UIView()
        self.addSubview(contentView)
        
        self.titleLabel = UILabel()
        self.contentView.addSubview(titleLabel)
        
        self.messageLabel = UILabel()
        self.contentView.addSubview(messageLabel)
        
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.contentView.addSubview(progressView)
        
        self.remaidLabel = UILabel()
        self.contentView.addSubview(remaidLabel)
    
        self.setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true
        
        self.titleLabel.textColor = UIColor.darkText
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 2
        
        self.messageLabel.textColor = UIColor.darkGray
        self.messageLabel.font = UIFont.systemFont(ofSize: 13)
        self.messageLabel.textAlignment = .left
        self.messageLabel.numberOfLines = 0
        
        self.progressView.layer.cornerRadius = progress_height
        self.progressView.clipsToBounds = true
        self.progressView.backgroundColor = UIColor.clear
        self.progressView.trackTintColor = #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)
        self.progressView.progressTintColor = #colorLiteral(red: 0.2862745098, green: 0.5176470588, blue: 0.937254902, alpha: 1)
        
        self.remaidLabel.textColor = UIColor.darkText
        self.remaidLabel.font = UIFont.systemFont(ofSize: 13)
        self.remaidLabel.textAlignment = .center
    }
    
    private let h_merge: CGFloat = 16
    private let v_merge: CGFloat = 10
    private let top_merge: CGFloat = 10
    private let bottom_merge: CGFloat = 15
    private let text_height: CGFloat = 20
    private let progress_height: CGFloat = 3
    
    private func setSubviewsLayout() {
        self.removeConstraints(self.constraints)
        self.contentView.removeConstraints(self.contentView.constraints)
        
        UIView.setNeedLayout([contentView, titleLabel, messageLabel, progressView, remaidLabel])
        
        contentView.autoLayoutCenterY(0, .equal)
        contentView.autoLayoutLeft(h_merge, .equal)
        contentView.autoLayoutRight(-h_merge, .equal)
        
        if let text = titleLabel.text, text.count > 0, let font = titleLabel.font {
            let width = self.bounds.width - h_merge * 2
            let height = text.getHeight(font, width) + 10
            titleLabel.autoLayoutTop(top_merge, .equal)
            titleLabel.autoLayoutLeft(h_merge, .equal)
            titleLabel.autoLayoutRight(-h_merge, .equal)
            titleLabel.autoLayoutHeight(height, .equal)
            
            messageLabel.autoLayoutTopRelative(v_merge, .equal, titleLabel)
        }else {
            messageLabel.autoLayoutTop(top_merge, .equal)
        }
        
        messageLabel.autoLayoutLeft(h_merge, .equal)
        messageLabel.autoLayoutRight(-h_merge, .equal)
        if let text = messageLabel.text, let font = messageLabel.font {
            let width = self.bounds.width - h_merge * 2
            let height = text.getHeight(font, width)
            messageLabel.autoLayoutHeight(height, .equal)
            
            if height < text_height {
                messageLabel.textAlignment = .center
            }else {
                messageLabel.textAlignment = .left
            }
        }
        
        progressView.autoLayoutTopRelative(v_merge, .equal, messageLabel)
        progressView.autoLayoutLeft(h_merge, .equal)
        progressView.autoLayoutRight(-h_merge, .equal)
        progressView.autoLayoutHeight(progress_height, .equal)
        
        remaidLabel.autoLayoutTopRelative(v_merge, .equal, progressView)
        remaidLabel.autoLayoutLeft(h_merge, .equal)
        remaidLabel.autoLayoutRight(-h_merge, .equal)
        remaidLabel.autoLayoutHeight(text_height, .equal)
        remaidLabel.autoLayoutBottom(-bottom_merge, .equal)
    }
    
}
