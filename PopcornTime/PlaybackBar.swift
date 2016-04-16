//
//  ScrubBar.swift
//  VLCPlayer
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

class PlaybackBar: UIView {
    
    private let playbackBarBorderColor = UIColor(red: 0.925, green: 0.922, blue: 0.918, alpha: 0.8)
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    var filled = false {
        didSet {
            if filled {
                fill()
            } else {
                unfill()
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            if !blurView.hidden {
                blurView.frame = bounds
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureView() {
        layer.cornerRadius = 6
        layer.borderColor = playbackBarBorderColor.CGColor
        layer.borderWidth = 3
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeZero
        layer.shadowOpacity = 0.8
        self.addSubview(blurView)
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        blurView.frame = self.frame
        unfill()
    }
    
    private func unfill() {
        blurView.hidden = true
        layer.borderWidth = 3
        layer.shadowOpacity = 0.8
    }
    
    private func fill() {
        blurView.hidden = false
        layer.borderWidth = 0
        layer.shadowOpacity = 0
    }

}
