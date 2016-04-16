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
            nameLabel.text = "Processing " + movieName + "..."
            imageView.kf_setImageWithURL(NSURL(string: imageAddress)!)
            backgroundImageView.kf_setImageWithURL(NSURL(string: backgroundImageAddress)!)

            if downloading {
                return
            }

            PTTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(magnet, progress: { status in
                self.downloading = true
                self.progressView.progress = status.bufferingProgress
                if self.progressView.progress <= 0.0 {
                    self.nameLabel.text = "Downloading " + self.movieName + "..."
                }
            }, readyToPlay: { url in
                self.playVLCVideo(url)
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
    
    func playVLCVideo(url: NSURL) {
        Kitchen.appController.navigationController.popViewControllerAnimated(false)
        let playerViewController = PopcornVLCPlayerViewController()
        playerViewController.url = url
        Kitchen.appController.navigationController.pushViewController(playerViewController, animated: true)
        self.streaming = true
    }

    func playNativeVideo(url: NSURL) {
        let mediaItem = AVPlayerItem(URL: url)

        let titleMetadataItem = AVMutableMetadataItem()
        titleMetadataItem.locale = NSLocale.currentLocale()
        titleMetadataItem.key = AVMetadataCommonKeyTitle
        titleMetadataItem.keySpace = AVMetadataKeySpaceCommon
        titleMetadataItem.value = self.movieName
        mediaItem.externalMetadata.append(titleMetadataItem)

        let descriptionMetadataItem = AVMutableMetadataItem()
        descriptionMetadataItem.locale = NSLocale.currentLocale()
        descriptionMetadataItem.key = AVMetadataCommonKeyDescription
        descriptionMetadataItem.keySpace = AVMetadataKeySpaceCommon
        descriptionMetadataItem.value = self.shortDescription
        mediaItem.externalMetadata.append(descriptionMetadataItem)

        if let image = self.imageView.image {
            let artworkMetadataItem = AVMutableMetadataItem()
            artworkMetadataItem.locale = NSLocale.currentLocale()
            artworkMetadataItem.key = AVMetadataCommonKeyArtwork
            artworkMetadataItem.keySpace = AVMetadataKeySpaceCommon
            artworkMetadataItem.value = UIImagePNGRepresentation(image)

            mediaItem.externalMetadata.append(artworkMetadataItem)
        }

        Kitchen.appController.navigationController.popViewControllerAnimated(false)
        let playerController = PlayerViewController()
        playerController.player = AVPlayer(playerItem: mediaItem)
        playerController.player?.play()
        Kitchen.appController.navigationController.pushViewController(playerController, animated: true)
        self.streaming = true
    }

}
