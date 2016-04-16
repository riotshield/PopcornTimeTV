//
//  PlayerControlsLabel.swift
//  VLCPlayer
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

class PlayerControlsLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureView() {
        self.backgroundColor = UIColor.clearColor()
        self.textColor = UIColor(red: 0.925, green: 0.922, blue: 0.918, alpha: 1.00)
        self.font = UIFont.boldSystemFontOfSize(35.0)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSizeZero
        self.layer.masksToBounds = false
        self.layer.shouldRasterize = true
    }
    
}
