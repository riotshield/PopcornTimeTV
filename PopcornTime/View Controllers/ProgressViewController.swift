//
//  ProgressViewController.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/18/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import UIKit
import PopcornTorrent
import AVKit
import TVMLKitchen
import Kingfisher

class ProgressViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!

    var magnet: String!
    var imageAddress: String!
    var backgroundImageAddress: String!
    var movieName: String!
    var shortDescription: String!

    var downloading = false
    var streaming = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let _ = magnet, let _ = movieName, let _ = imageAddress, let _ = backgroundImageAddress {
            statsLabel.text = ""
            percentLabel.text = "0%"
            nameLabel.text = "Processing " + movieName + "..."
            imageView.kf_setImageWithURL(NSURL(string: imageAddress)!)
            backgroundImageView.kf_setImageWithURL(NSURL(string: backgroundImageAddress)!)

            if downloading {
                return
            }
            
            PTTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(magnet, progress: { status in
                self.downloading = true

                self.percentLabel.text = "\(Int(status.bufferingProgress * 100))%"

                let speedString = NSByteCountFormatter.stringFromByteCount(Int64(status.downloadSpeed), countStyle: .Binary)
                self.statsLabel.text = "Speed: \(speedString)/s  Seeds: \(status.seeds)  Peers: \(status.peers)  Overall Progress: \(Int(status.totalProgreess*100))%"

                self.progressView.progress = status.bufferingProgress
                if self.progressView.progress > 0.0 {
                    self.nameLabel.text = "Buffering " + self.movieName + "..."
                }

                print("\(Int(status.bufferingProgress*100))%, \(Int(status.totalProgreess*100))%, \(speedString), Seeds: \(status.seeds), Peers: \(status.peers)")
            }, readyToPlay: { url in
                self.playVLCVideo(url, hash: "")
            }) { error in
                print(error)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if !self.streaming {
            PTTorrentStreamer.sharedStreamer().cancelStreaming()
        }
    }

    func playVLCVideo(url: NSURL, hash: String) {
        AudioManager.sharedManager().stopTheme()
        
        Kitchen.appController.navigationController.popViewControllerAnimated(false)
        let playerViewController = SYVLCPlayerViewController(URL: url, andHash: hash)
        Kitchen.appController.navigationController.pushViewController(playerViewController, animated: true)
        self.streaming = true
    }

}
