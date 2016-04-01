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
        case "showMovies": Kitchen.serve(recipe: KitchenTabBar(items: [Popular(), Latest(),  MovieWatchlist(), Search()]))

        case "showTVShows":
            var popular = Popular()
            popular.fetchType = .Shows
            var search = Search()
            search.fetchType = .Shows
            let tabBar = KitchenTabBar(items: [popular, search, ShowWatchlist()])
            Kitchen.serve(recipe: tabBar)

        case "showMovie": showMovie(pieces)
        case "showShow": showShow(pieces)

        case "showSeason": showSeason(pieces)
        case "showEpisode": showEpisode(pieces)

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

    /**
     The action handler for when a tab is cahnged
     
     - parameter id: The tabID of the element pressed
     */
    static func tabChanged(id: Int) {
        
    }
    
    // MARK: Actions

    static func showMovie(pieces: [String]) {
        NetworkManager.sharedManager().showDetailsForMovie(movieId: Int(pieces.last!)!, withImages: false, withCast: true) { movie, error in
            if let movie = movie {
                NetworkManager.sharedManager().suggestionsForMovie(movieId: Int(pieces.last!)!, completion: { movies, error in
                    if let movies = movies {
                        WatchlistManager.sharedManager().itemExistsInWatchList(itemId: String(movie.id), forType: .Movie, completion: { exists in
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
        var presentedDetails = false
        let showId = pieces[1]
        let imdbSlug = pieces[2]
        let tvdbId = pieces[3]

        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            if let show = show {
                var seasonsDictionary = [Int : [Episode]]()
                for episode in show.episodes {
                    if let episodes = seasonsDictionary[episode.season] {
                        var episodes = episodes
                        episodes.append(episode)
                        seasonsDictionary[episode.season] = episodes
                    } else {
                        seasonsDictionary[episode.season] = [episode]
                    }
                }

                var seasons = [Season]()
                manager.fetchTraktSeasonInfoForIMDB(imdbSlug) { response, error in
                    if let response = response {
                        for (key, value) in seasonsDictionary {
                            var season = Season()
                            season.seasonNumber = key
                            season.episodes = value
                            if response.indices.contains(key) {
                                let seasonInfo = response[key]
                                if let images = seasonInfo["images"] as? [String : AnyObject] {
                                    if let posters = images["poster"] as? [String : String] {
                                        season.seasonLargeCoverImage = posters["full"]
                                        season.seasonMediumCoverImage = posters["medium"]
                                        season.seasonSmallCoverImage = posters["thumb"]
                                    }
                                }
                                seasons.append(season)
                            }

                            manager.searchTVDBSeries(Int(tvdbId)!) { response, error in
                                if let response = response {
                                    if !presentedDetails {
                                        let recipe = ShowProductRecipe(show: show, showInfo: ShowInfo(xml: response), seasons: seasons, existsInWatchList: false)
                                        Kitchen.serve(recipe: recipe)
                                        presentedDetails = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func showSeason(pieces: [String]) {
        var presentedDetails = false
        let showId = pieces[1]
        let seasonNumber = pieces[2]
        let imdbSlug = pieces[3]
        let tvdbId = pieces[4]

        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            if let show = show {
                manager.fetchTraktSeasonEpisodesInfoForIMDB(imdbSlug, season: Int(seasonNumber)!) { response, error in
                    if let response = response {
                        var episodes = [Episode]()
                        for episode in show.episodes {
                            if Int(seasonNumber)! == episode.season {
                                episodes.append(episode)
                            }
                        }
                        episodes.sortInPlace({ $0.episode < $1.episode })

                        var detailedEpisodes = [DetailedEpisode]()
                        for (index, item) in response.enumerate() {
                            var episode = DetailedEpisode()
                            if episodes.indices.contains(index) {
                                episode.episode = episodes[index]
                                if let title = item["title"] as? String {
                                    episode.episodeTitle = title
                                }
                                if let images = item["images"] as? [String : AnyObject] {
                                    if let screenshots = images["screenshot"] as? [String : String] {
                                        episode.fullScreenshot = screenshots["full"]
                                        episode.mediumScreenshot = screenshots["medium"]
                                        episode.smallScreenshot = screenshots["thumb"]
                                    }
                                }
                                detailedEpisodes.append(episode)
                            }
                        }

                        manager.searchTVDBSeries(Int(tvdbId)!) { response, error in
                            if let response = response {
                                if !presentedDetails {
                                    let recipe = EpisodesProductRecipe(show: show, showInfo: ShowInfo(xml: response), episodes: episodes, detailedEpisodes: detailedEpisodes)
                                    Kitchen.serve(recipe: recipe)
                                    presentedDetails = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func showEpisode(pieces: [String]) {
        var presentedDetails = false
        let showId = pieces[1]
        let seasonNumber = pieces[2]
        let imdbSlug = pieces[3]
        let tvdbId = pieces[4]
        let episodeNumber = pieces[6]

        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            if let show = show {
                manager.fetchTraktSeasonEpisodesInfoForIMDB(imdbSlug, season: Int(seasonNumber)!) { response, error in
                    if let response = response {
                        var episodes = [Episode]()
                        for episode in show.episodes {
                            if Int(seasonNumber)! == episode.season {
                                episodes.append(episode)
                            }
                        }
                        episodes.sortInPlace({ $0.episode < $1.episode })

                        var detailedEpisodes = [DetailedEpisode]()
                        for (index, item) in response.enumerate() {
                            var episode = DetailedEpisode()
                            if episodes.indices.contains(index) {
                                episode.episode = episodes[index]
                                if let title = item["title"] as? String {
                                    episode.episodeTitle = title
                                }
                                if let images = item["images"] as? [String : AnyObject] {
                                    if let screenshots = images["screenshot"] as? [String : String] {
                                        episode.fullScreenshot = screenshots["full"]
                                        episode.mediumScreenshot = screenshots["medium"]
                                        episode.smallScreenshot = screenshots["thumb"]
                                    }
                                }
                                detailedEpisodes.append(episode)
                            }
                        }

                        manager.searchTVDBSeries(Int(tvdbId)!) { response, error in
                            if let response = response {
                                if !presentedDetails {
                                    let recipe = EpisodeProductRecipe(show: show, showInfo: ShowInfo(xml: response), episodes: episodes, detailedEpisodes: detailedEpisodes, episodeNumber: Int(episodeNumber)!)
                                    Kitchen.serve(recipe: recipe)
                                    presentedDetails = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func playMovie(pieces: [String]) {
        print(pieces)
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
        print(pieces)
        let name = pieces[2]
        let id = pieces[1]
        let type = pieces[3]
        let cover = pieces[4] + ":" + pieces[5]
        var imdb = ""
        if pieces.indices.contains(6) {
            imdb = pieces[6]
        }
        var tvdb = ""
        if pieces.indices.contains(7) {
            tvdb = pieces[7]
        }
        WatchlistManager.sharedManager().itemExistsInWatchList(itemId: id, forType: ItemType(rawValue: type)!, completion: { exists in
            if exists {
                WatchlistManager.sharedManager().removeItemFromWatchList(WatchItem(name: name, id: id, coverImage: cover, type: type, imdbId: imdb, tvdbId: tvdb), completion: { removed in
                    if removed {
                        Kitchen.serve(recipe: AlertRecipe(title: "Removed", description: "\(name) was removed from your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    } else {
                        Kitchen.serve(recipe: AlertRecipe(title: "Not Found", description: "\(name) is not found in your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    }
                })
            } else {
                WatchlistManager.sharedManager().addItemToWatchList(WatchItem(name: name, id: id, coverImage: cover, type: type, imdbId: imdb, tvdbId: tvdb), completion: { added in
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
