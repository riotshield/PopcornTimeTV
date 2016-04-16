//
//  Scrubber.swift
//  VLCPlayer
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

class PositionIndicator: UIView {
    
    let indicatorWidth = CGFloat(3)
    let indicatorColor = UIColor(red: 0.925, green: 0.922, blue: 0.918, alpha: 0.9)
    
    var indicatorHeight = CGFloat(12) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var upsideDown = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let timeLabel: PlayerControlsLabel
    let indicator: UIView
    
    override init(frame: CGRect) {
        self.timeLabel = PlayerControlsLabel()
        self.indicator = UIView()
        super.init(frame: frame)
        addSubview(self.timeLabel)
        addSubview(self.indicator)
        
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.timeLabel = PlayerControlsLabel()
        self.indicator = UIView()
        super.init(coder: aDecoder)
        addSubview(self.timeLabel)
        addSubview(self.indicator)
        
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        
        let viewFrame = self.frame
        
        let indicatorFrame: CGRect
        let timeLabelFrame: CGRect
        
        if upsideDown {
            indicatorFrame = CGRectMake((viewFrame.width + indicatorWidth)/2, viewFrame.height - indicatorHeight, indicatorWidth, indicatorHeight)
            timeLabelFrame = CGRectMake(0.0, 0.0, viewFrame.width, viewFrame.height - indicatorHeight)
        } else {
            indicatorFrame = CGRectMake((viewFrame.width + indicatorWidth)/2, 0.0, indicatorWidth, indicatorHeight)
            timeLabelFrame = CGRectMake(0.0, indicatorHeight, viewFrame.width, viewFrame.height - indicatorHeight)
        }
        
        indicator.frame = indicatorFrame
        timeLabel.frame = timeLabelFrame
        
        indicator.backgroundColor = indicatorColor
        timeLabel.textAlignment = NSTextAlignment.Center
        
    }
    
}
