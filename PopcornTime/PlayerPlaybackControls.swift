//
//  PlayerPlaybackControls.swift
//  VLCPlayer
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

class PlayerPlaybackControls: UIView {
    
    // MARK: Private
    
    private let scrubBarHeight = CGFloat(12)
    private let horizontalMargin = CGFloat(90)
    private let verticalMargin = CGFloat(100)
    private let labelWidth = CGFloat(100)
    private let labelHeight = CGFloat(40)
    
    private let totalTimeLabel = PlayerControlsLabel()
    private let playbackIndicator = PositionIndicator()
    private let seekIndicator = PositionIndicator()
    private let bufferBar = PlaybackBar()
    private let playbackBar = PlaybackBar()
    
    private var _playback = 0.0 as Float {
        didSet {
            updateIndicatorPosition(playbackIndicator, progress: playback, hidesTime: true)
        }
    }
    
    private var _bufferIndicator = 0.0 as Float {
        didSet {
            if !self.hidden {
                updateBufferOverlay()
            }
        }
    }
    
    private var _seek = 0.0 as Float {
        didSet {
            updateIndicatorPosition(seekIndicator, progress: seek, hidesTime: false)
        }
    }
    
    override var hidden: Bool {
        willSet {
            if newValue {
                updateIndicatorPosition(playbackIndicator, progress: playback, hidesTime: true)
            }
        }
    }
    
    // MARK: Properties
    
    var playback: Float {
        get {
            return _playback
        }
        
        set (newPlayback) {
            if newPlayback >= 0 && newPlayback <= 1 {
                _playback = newPlayback
            }
        }
    }
    
    var playbackTime = "" {
        didSet {
            playbackIndicator.timeLabel.text = playbackTime
        }
    }
    
    var totalTime = "" {
        didSet {
            totalTimeLabel.text = totalTime
        }
    }
    
    var seek: Float {
        get {
            return _seek
        }
        set (newSeek) {
            if newSeek >= 0 && newSeek <= 1 {
                _seek = newSeek
            }
        }
    }
    
    var seekTime =  "" {
        didSet {
            seekIndicator.timeLabel.text = seekTime
        }
    }
    
    var seeking = false {
        willSet {
            if newValue {
                updateIndicatorPosition(seekIndicator, progress: playback, hidesTime: true)
            }
            seekIndicator.hidden = !newValue
        }
    }
    
    var buffer: Float {
        get {
            return _bufferIndicator
        }
        set(newBufferIndicator) {
            if newBufferIndicator >= 0 && newBufferIndicator <= 1 {
                _bufferIndicator = newBufferIndicator
            }
        }
    }
    
    // MARK: Public functions 
    
    func hideControls() {
        hidden = true
    }
    
    func showControls() {
        hidden = false
    }
    
    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
        
        setNeedsDisplay()
    }
    
    private func configureView() {
        self.addSubview(totalTimeLabel)
        self.addSubview(playbackBar)
        self.addSubview(bufferBar)
        self.addSubview(playbackIndicator)
        self.addSubview(seekIndicator)
        
        seekIndicator.indicatorHeight = 24
        seekIndicator.upsideDown = true
        seekIndicator.hidden = true
        bufferBar.filled = true
    }
    
    override func setNeedsDisplay() {
        
        let playerFrame = self.frame
        
        let playbackBarFrame = CGRectMake(playerFrame.origin.x + horizontalMargin,
                                       playerFrame.size.height - verticalMargin,
                                       playerFrame.size.width - horizontalMargin*2,
                                       scrubBarHeight)
        playbackBar.frame = playbackBarFrame
        
        let bufferBarFrame = CGRectMake(playbackBarFrame.origin.x, playbackBarFrame.origin.y, 0.0, playbackBarFrame.height)
        bufferBar.frame = bufferBarFrame
        
        let totalTimeLabelFrame = CGRectMake(playerFrame.width - horizontalMargin - labelWidth,
                                             playerFrame.height - verticalMargin + labelHeight/2,
                                             labelWidth,
                                             labelHeight)
        totalTimeLabel.frame = totalTimeLabelFrame
        
        let playbackIndicatorFrame = CGRectMake(playbackBarFrame.origin.x - labelWidth/2, playbackBarFrame.origin.y,
                                                labelWidth, playerFrame.height - totalTimeLabelFrame.origin.y - playbackBarFrame.height)
        playbackIndicator.frame = playbackIndicatorFrame
        
        let seekIndicatorFrame = CGRectMake(playbackBarFrame.origin.x - labelWidth/2,
                                            playbackBarFrame.origin.y + playbackBarFrame.height - playbackIndicatorFrame.height,
                                           labelWidth, playbackIndicatorFrame.height)
        seekIndicator.frame = seekIndicatorFrame
        
    }
    
    private func updateBufferOverlay() {
        
        let playerFrame = self.frame
        
        let full = playerFrame.size.width - (horizontalMargin * 2)
        
        let newWidth = CGFloat(buffer) * full
        
        var bufferFrame = bufferBar.frame
        bufferFrame.size.width = newWidth
        bufferBar.frame = bufferFrame
        
    }
    
    private func updateIndicatorPosition(indicator: PositionIndicator, progress: Float, hidesTime: Bool) {
        
        let playerFrame = self.frame
        
        let zero = horizontalMargin - labelWidth/2
        let full = playerFrame.size.width - (horizontalMargin * 2) - 5.0
        
        let newXPosition = CGFloat(progress) * full + zero
        
        var indicatorFrame = indicator.frame
        indicatorFrame.origin.x = newXPosition
        indicator.frame = indicatorFrame
        
        if hidesTime {
            if full - newXPosition < (labelWidth + 20.0) {
                totalTimeLabel.hidden = true
            } else {
                totalTimeLabel.hidden = false
            }
        }
    }
    
}
