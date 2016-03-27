//
//  ActionHandler.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 15/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit
import PopcornTorrent
import YoutubeSourceParserKit
import AVKit

struct ActionHandler {

    /**
     The action handler for when the primary (select) button is pressed

     - parameter id: The actionID of the element pressed
     */
    static func primary(id: String) {
        let pieces = id.componentsSeparatedByString(":")
        switch pieces.first! { // swiftlint:disable:this force_cast
        case "showMovies": break
//            let tabbar = KitchenTabBar()
//            tabBar.items = [
//                Popular(),
//                Latest(),
//                MovieWatchlist(),
//                Search()
//            ]
//            Kitchen.serve(recipe: tabBar)
            
        case "showTVShows":
//            var popular = Popular()
//            popular.fetchType = .Shows
//            let tabbar = KitchenTabBar()
//            tabBar.items = [
//                popular
//            ]
//            Kitchen.serve(recipe: tabBar)
            
            var popular = Popular()
            popular.fetchType = .Shows
            KitchenTabBar.sharedBar.items = [
                popular
            ]
            
        case "showMovie": showMovie(pieces)
        case "showShow": showShow(pieces)
            
        case "playMovie": playMovie(pieces)
        case "playPreview": playPreview(pieces)
        case "addWatchlist": addWatchlist(pieces)
        case "closeAlert": Kitchen.dismissModal()
        case "showDescription": Kitchen.serve(recipe: DescriptionRecipe(title: pieces[1], description: pieces.last!))
            
        default: break
        }

    }

    /**
     The action handler for when the play button is pressed

     - parameter id: The actionID of the element pressed
     */
    static func play(id: String) {

    }

    // MARK: Actions

    static func showMovie(pieces: [String]) {
        NetworkManager.sharedManager().showDetailsForMovie(movieId: Int(pieces.last!)!, withImages: false, withCast: true) { movie, error in
            if let movie = movie {
                NetworkManager.sharedManager().suggestionsForMovie(movieId: Int(pieces.last!)!, completion: { movies, error in
                    if let movies = movies {
                        WatchlistManager.sharedManager().itemExistsInWatchList(itemId: movie.id, forType: .Movie, completion: { exists in
                            let product = MovieProductRecipe(movie: movie, suggestions: movies, existsInWatchList: exists)
                            Kitchen.serve(recipe: product)
                        })
                    } else if let _ = error {

                    }
                })
            } else if let _ = error {

            }
        }
    }
    
    static func showShow(pieces: [String]) {
        let showId = pieces[1]
        let tvdbId = pieces[2]
        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            var seasons = [Season]()
            manager.searchTVDBSeries(Int(tvdbId)!) { response, error in
                print(response)
            }
            
            var seasonsDictionary = [Int : [Episode]]()
            for episode in show!.episodes {
                if let episodes = seasonsDictionary[episode.season] {
                    var episodes = episodes
                    episodes.append(episode)
                    seasonsDictionary[episode.season] = episodes
                } else {
                    seasonsDictionary[episode.season] = [episode]
                }
            }
        }
    }

    static func playMovie(pieces: [String]) {
        // {{MAGNET}}:https:{{IMAGE}}:http:{{BACKGROUND_IMAGE}}:{{TITLE}}:{{SHORT_DESCRIPTION}}
        let magnet = "magnet:?xt=urn:btih:\(pieces[1])&tr=" + Trackers.map { $0 }.joinWithSeparator("&tr=")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("ProgressViewController") as? ProgressViewController {
            viewController.magnet = magnet
            viewController.imageAddress = pieces[3]
            viewController.backgroundImageAddress = pieces[5]
            viewController.movieName = pieces[6]
            viewController.shortDescription = pieces[7]

            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                Kitchen.appController.navigationController.pushViewController(viewController, animated: true)
            })
        }
    }

    static func playPreview(pieces: [String]) {
        Youtube.h264videosWithYoutubeURL(NSURL(string: pieces.last!)!, completion: { videoInfo, error in
            if let videoInfo = videoInfo {
                if let url = videoInfo["url"] as? String {
                    let playerController = AVPlayerViewController()
                    playerController.player = AVPlayer(URL: NSURL(string: url)!)
                    playerController.player?.play()
                    Kitchen.appController.navigationController.pushViewController(playerController, animated: true)
                }
            }
        })
    }

    static func addWatchlist(pieces: [String]) {
        let name = pieces[2]
        let id = pieces[1]
        let type = pieces[3]
        let cover = pieces[4] + ":" + pieces[5]
        WatchlistManager.sharedManager().itemExistsInWatchList(itemId: Int(id)!, forType: .Movie, completion: { exists in
            if exists {
                WatchlistManager.sharedManager().removeItemFromWatchList(WatchItem(name: name, id: Int(id)!, coverImage: cover, type: type), completion: { removed in
                    if removed {
                        Kitchen.serve(recipe: AlertRecipe(title: "Removed", description: "\(name) was removed from your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    } else {
                        Kitchen.serve(recipe: AlertRecipe(title: "Not Found", description: "\(name) is not found in your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    }
                })
            } else {
                WatchlistManager.sharedManager().addItemToWatchList(WatchItem(name: name, id: Int(id)!, coverImage: cover, type: type), completion: { added in
                    if added {
                        Kitchen.serve(recipe: AlertRecipe(title: "Added", description: "\(name) was added your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    } else {
                        Kitchen.serve(recipe: AlertRecipe(title: "Already Added", description: "\(name) is already in your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    }
                })
            }

        })
    }

}
