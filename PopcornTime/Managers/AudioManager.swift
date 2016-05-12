//
//  AudioManager.swift
//  PopcornTime
//
//  Created by Yogi Bear on 5/11/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import Foundation

class AudioManager : NSObject, VLCMediaPlayerDelegate {
    
    var player: VLCMediaPlayer!
    var currentPlayingThemeId: Int!
    
    class func sharedManager() -> AudioManager {
        struct Struct {
            static let Instance = AudioManager()
        }
        
        return Struct.Instance
    }
    
    override init() {
        super.init()
        
        self.player = VLCMediaPlayer()
        self.player.delegate = self
    }
    
    func playTheme(id: Int) {
        if let _ = self.currentPlayingThemeId {
            if self.currentPlayingThemeId == id {
                return
            }
        }
        
        if self.player.playing {
            self.player.stop()
        }
        
        self.currentPlayingThemeId = id
        self.player.media = VLCMedia(URL: NSURL(string: "http://tvthemes.plexapp.com/\(id).mp3")!)
        self.player.play()
    }
    
    func stopTheme() {
        self.player.stop()
    }
    
    @objc func mediaPlayerStateChanged(aNotification: NSNotification!) {
        if let player = aNotification.object as? VLCMediaPlayer {
            switch player.state {
            case .Playing: break
            case .Buffering: break
            case .Stopped: self.currentPlayingThemeId = nil
            default: break
            }
        }
    }
    
}
