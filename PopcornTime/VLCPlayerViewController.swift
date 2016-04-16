//
//  VLCPlayerViewController.swift
//  PopcornTime
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import UIKit

private enum PlayerControlState {
    case Hidden, ShownWithoutScrubber, ShownWithScrubber
}

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate {

    //hack
    private var firstStop = true
    
    private let mediaPlayer = VLCMediaPlayer()
    private let dimView = UIView()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    private var updatePosition = false
    private var playerControls = PlayerPlaybackControls()
    private var playerControlState = PlayerControlState.Hidden {
        didSet {
            updateSubviewsForPlayerControlState(playerControlState)
        }
    }
    
    var buffer = 0.0 as Float {
        didSet {
            playerControls.buffer = buffer
        }
    }
    
    var url = NSURL(string:"")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        configureView()
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.blackColor()
        
        dimView.frame = view.frame
        dimView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        view.addSubview(dimView)
        
        var indicatorFrame = activityIndicator.frame
        indicatorFrame.origin.x = (view.frame.size.width - indicatorFrame.size.width)/2
        indicatorFrame.origin.y = (view.frame.size.height - indicatorFrame.size.height)/2
        activityIndicator.frame = indicatorFrame
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let playerControlsFrame = CGRectMake(0.0, self.view.frame.size.height - 200.0, self.view.frame.size.width, 200.0)
        playerControls = PlayerPlaybackControls(frame: playerControlsFrame)
        playerControls.hidden = true
        view.addSubview(playerControls)
        
        let playPauseGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(playPausePressed))
        playPauseGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        view.addGestureRecognizer(playPauseGestureRecognizer)
        
        let selectButtonGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(selectButton))
        selectButtonGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view.addGestureRecognizer(selectButtonGestureRecognizer)
        
        let menuGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(menuButtonPressed))
        menuGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Menu.rawValue)]
        view.addGestureRecognizer(menuGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tappedSurface))
        tapGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.DownArrow.rawValue),
                                                  NSNumber(integer: UIPressType.UpArrow.rawValue),
                                                  NSNumber(integer: UIPressType.LeftArrow.rawValue),
                                                  NSNumber(integer: UIPressType.RightArrow.rawValue)]
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Gesture recognizer selectors
    
    func selectButton() {
        updatePosition = true
        
        if mediaPlayer.playing {
            playerControlState = PlayerControlState.ShownWithScrubber
            mediaPlayer.pause()
        } else {
            if playerControls.seeking {
                if abs(playerControls.seek - playerControls.playback) < 0.005 {
                    playerControlState = PlayerControlState.Hidden
                    mediaPlayer.play()
                } else {
                    bringToFrontAndShow(activityIndicator)
                    mediaPlayer.play()
                }
            } else {
                playerControlState = PlayerControlState.Hidden
                mediaPlayer.play()
            }
        }
        
    }
    
    func tappedSurface() {
        switch playerControlState {
        case .ShownWithoutScrubber:
            playerControlState = PlayerControlState.Hidden
            break
        case .Hidden:
            playerControlState = PlayerControlState.ShownWithoutScrubber
            break
        case .ShownWithScrubber:
            break
        }
    }
    
    func playPausePressed() {
        updatePosition = true
        
        if mediaPlayer.playing {
            playerControlState = PlayerControlState.ShownWithScrubber
            mediaPlayer.pause()
        } else {
            playerControlState = PlayerControlState.Hidden
            mediaPlayer.play()
        }
    }
    
    func menuButtonPressed() {
        updatePosition = false
        
        switch playerControlState {
        case .Hidden:
            mediaPlayer.stop()
            break
        default:
            playerControlState = PlayerControlState.Hidden
            mediaPlayer.play()
        }
        
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Cancelled, UIGestureRecognizerState.Failed :
            return
        default:
            break
        }
        
        switch playerControlState {
        case .Hidden:
            return
        case .ShownWithoutScrubber:
            mediaPlayer.pause()
            playerControlState = PlayerControlState.ShownWithScrubber
            return
        case .ShownWithScrubber:
            var translation = recognizer.translationInView(view)
            
            let scaleFactor = 8.0 as Float
            let seekInView = Float(translation.x/CGRectGetWidth(view.bounds))/scaleFactor
            
            let seekingFraction = max(0.0, min(playerControls.seek + seekInView, 1.0))
            
            translation.x = CGFloat(0.0)
            recognizer.setTranslation(translation, inView: view)
            
            playerControls.seek = seekingFraction
            updateTimeLabelForSeekingFactor(seekingFraction)
        }
        
    }
    
    // MARK: Media Player Delegate
    
    func mediaPlayerTimeChanged(aNotification: NSNotification!) {
        playerControls.playback = mediaPlayer.position
        playerControls.playbackTime = mediaPlayer.time.stringValue
        playerControls.seek = mediaPlayer.position
        playerControls.seekTime = mediaPlayer.time.stringValue
        playerControls.totalTime = mediaPlayer.media.length.stringValue
    }
    
    func mediaPlayerStateChanged(aNotification: NSNotification!) {
        
        if (mediaPlayer.state == VLCMediaPlayerState.Playing) && updatePosition {
            activityIndicator.hidden = true
            playerControls.playback = playerControls.seek
            playerControls.playbackTime = playerControls.seekTime
            mediaPlayer.position = playerControls.seek
            playerControlState = PlayerControlState.Hidden
        } else if (mediaPlayer.state == VLCMediaPlayerState.Stopped && firstStop) {
            firstStop = false
            destroyViewController()
        }
        
    }
    
    // MARK: Helper methods
    
    private func updateSubviewsForPlayerControlState(state: PlayerControlState) {
        switch state {
        case .Hidden:
            hideControls()
            break
        case .ShownWithoutScrubber:
            playerControls.seeking = false
            showControls()
            break
        case .ShownWithScrubber:
            playerControls.seeking = true
            showControls()
            break
        }
    }
    
    private func updateTimeLabelForSeekingFactor(seekingFactor: Float) {
        let seekingTimeInt = Int32(max(1, Float(mediaPlayer.media.length.intValue) * seekingFactor))
        let seekingTime = VLCTime(int: seekingTimeInt)
        playerControls.seekTime = seekingTime.stringValue
    }
    
    private func showControls() {
        playerControls.seek = playerControls.playback
        playerControls.seekTime = playerControls.playbackTime
        view.bringSubviewToFront(dimView)
        dimView.alpha = 0.0
        dimView.hidden = false
        view.bringSubviewToFront(playerControls)
        playerControls.alpha = 0.0
        playerControls.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.dimView.alpha = 1.0
            self.playerControls.alpha = 1.0
            
            }, completion: nil)
    }
    
    private func hideControls() {
        self.dimView.alpha = 1.0
        self.playerControls.alpha = 1.0
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.dimView.alpha = 0.0
            self.playerControls.alpha = 0.0
            
            }, completion: { success in
                self.dimView.hidden = true
                self.playerControls.hidden = true
        })
    }
    
    private func bringToFrontAndShow(aView: UIView) {
        view.bringSubviewToFront(aView)
        aView.hidden = false
    }
    
    // MARK: Lifecycle 
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self.view
        mediaPlayer.media = VLCMedia(URL: url)
        playerControls.totalTime = mediaPlayer.media.length.stringValue
        mediaPlayer.play()
    }
    
    func destroyViewController() {
        print("Method called when the VLCViewController must be destroyed. Override it.")
    }
    
}
