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

struct ActionHandler { // swiftlint:disable:this type_body_length

    /**
     The action handler for when the primary (select) button is pressed

     - parameter id: The actionID of the element pressed
     */
    static func primary(id: String) {
        let pieces = id.componentsSeparatedByString("»")
        switch pieces.first! { // swiftlint:disable:this force_cast
        case "showMovies": Kitchen.serve(recipe: KitchenTabBar(items: [Popular(), Latest(), Genre(), Watchlist(), Search()]))
        case "showTVShows":
            var latest = Latest()
            latest.fetchType = .Shows

            var popular = Popular()
            popular.fetchType = .Shows

            var genre = Genre()
            genre.fetchType = .Shows

            var search = Search()
            search.fetchType = .Shows

            var watchlist = Watchlist()
            watchlist.fetchType = .Shows

            let tabBar = KitchenTabBar(items: [popular, latest, genre, watchlist, search])
            Kitchen.serve(recipe: tabBar)

        case "showGlobalWatchlist":
            let watchlist = WatchlistManager.sharedManager()
            watchlist.fetchWatchListItems(forType: .Movie) { watchListMovies in
                watchlist.fetchWatchListItems(forType: .Show) { watchListShows in
                    Kitchen.serve(recipe: WatchlistRecipe(title: "Watchlist", watchListMovies: watchListMovies, watchListShows: watchListShows))
                }
            }

        case "showMovie": showMovie(pieces)
        case "showShow": showShow(pieces)

        case "showSettings": showSettings(pieces)

        case "showSeason": showSeason(pieces)
        case "showSeasons": showSeasons(pieces)

        case "playMovie": playMovie(pieces)
        case "playPreview": playPreview(pieces)
        case "addWatchlist": addWatchlist(pieces)
        case "closeAlert": Kitchen.dismissModal()
        case "showDescription": Kitchen.serve(recipe: DescriptionRecipe(title: pieces[1], description: pieces.last!))

        case "streamTorrent": streamTorrent(pieces)

        case "showActor": showCredits(pieces, isActor: true)
        case "showDirector": showCredits(pieces, isActor: false)

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

    static func showSettings(pieces: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                Kitchen.appController.navigationController.pushViewController(viewController, animated: true)
            })
        }
    }

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

    static func showCredits(pieces: [String], isActor: Bool = true) {
        Kitchen.serve(recipe: LoadingRecipe(message: pieces.last!)) // Show LoadingView

        NetworkManager.sharedManager().getCreditsForPerson(actorName: String(UTF8String: pieces.last!)!, isActor: isActor) { movies, shows, error in

            if error != nil {
                Kitchen.navigationController.popViewControllerAnimated(false) // Dismiss LoadingView
                return
            }

            if let _ = movies, let _ = shows {
                Kitchen.navigationController.popViewControllerAnimated(false) // Dismiss LoadingView
                var recipe = CatalogRecipe(title: pieces.last!, movies: movies, shows: shows)
                recipe.presentationType = .DefaultWithLoadingIndicator
                Kitchen.serve(recipe: recipe)
            } else {
                // To Do: Go back to the movie overview instead of main home view
                Kitchen.navigationController.popToRootViewControllerAnimated(false)
                let recipe = AlertRecipe(title: "Sorry, " + String(UTF8String: pieces.last!)! + " has no movies/tv shows", description: "This can happen because we are not using the same data sources for movies, tv shows and actors", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal)

                Kitchen.serve(recipe: recipe)
            }
        }

    }

    static func showShow(pieces: [String]) {
        showSeasonWithNumber(pieces, seasonNumber: -1)
    }

    static func showSeason(pieces: [String]) {
        showSeasonWithNumber(pieces, seasonNumber: Int(pieces[4])!)
    }

    static func showSeasonWithNumber(pieces: [String], seasonNumber: Int) {
        print(pieces)
        var presentedDetails = false
        let showId = pieces[1]
        let tvdbId = pieces[3]

        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            if let show = show {

                var existingSeasons = Set<Int>()

                for episode in show.episodes {
                    existingSeasons.insert(episode.season)
                }

                let seasons = Array(existingSeasons).sort()

                let seasonInfo = SeasonInfo(last:seasons.last!, first: seasons.first!, current: (seasonNumber == -1 ? seasons.last! : seasonNumber))

                manager.searchTVDBSeries(Int(tvdbId)!) { response, error in
                    if let xml = response {
                        let seriesInfo = xml["Data"]["Series"]

                        let slug = seriesInfo["SeriesName"].element!.text!.slugged

                        manager.fetchTraktSeasonEpisodesInfoForIMDB(slug, season: seasonInfo.current) { response, error in
                            if let response = response {
                                var episodes = [Episode]()
                                for episode in show.episodes {
                                    if seasonInfo.current == episode.season {
                                        episodes.append(episode)
                                    }
                                }
                                episodes.sortInPlace({ $0.episode < $1.episode })

                                var detailedEpisodes = [DetailedEpisode]()
                                for (_, item) in response.enumerate() {
                                    var episode = DetailedEpisode()
                                    for ep in episodes {
                                        if ep.episode == item["number"] as? Int {
                                            episode.episode = ep
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
                                }

                                if !presentedDetails {
                                    WatchlistManager.sharedManager().itemExistsInWatchList(itemId: String(show.id), forType: .Show, completion: { exists in
                                        let recipe = SeasonProductRecipe(show: show, showInfo: ShowInfo(xml: xml), episodes: episodes,
                                            detailedEpisodes: detailedEpisodes, seasonInfo: seasonInfo, existsInWatchlist: exists)

                                        Kitchen.appController.evaluateInJavaScriptContext({jsContext in
                                            let disableThemeSong: @convention(block) String -> Void = { message in
                                                AudioManager.sharedManager().stopTheme()
                                            }
                                            jsContext.setObject(unsafeBitCast(disableThemeSong, AnyObject.self),
                                                forKeyedSubscript: "disableThemeSong")
                                            if let file = NSBundle.mainBundle().URLForResource("SeasonProductRecipe", withExtension: "js") {
                                                do {
                                                    var js = try String(contentsOfURL: file)
                                                    js = js.stringByReplacingOccurrencesOfString("{{RECIPE}}", withString: recipe.xmlString)
                                                    jsContext.evaluateScript(js)
                                                } catch {
                                                    print("Could not open SeasonProductRecipe.js")
                                                }
                                            }
                                        }, completion: nil)
                                        presentedDetails = true
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func showSeasons(pieces: [String]) {
        let showId = pieces[1]
        let imdbSlug = pieces[2]

        let manager = NetworkManager.sharedManager()
        manager.fetchShowDetails(showId) { show, error in
            if let show = show {

                var existingSeasons = Set<Int>()

                for episode in show.episodes {
                    existingSeasons.insert(episode.season)
                }

                let seasonsArray = Array(existingSeasons).sort()

                var seasons = [Season]()
                manager.fetchTraktSeasonInfoForIMDB(imdbSlug) { response, error in
                    if let response = response {
                        for seasonNumber in seasonsArray {
                            var season = Season()
                            season.seasonNumber = seasonNumber
                            for (_, item) in response.enumerate() {
                                if item["number"] as? Int == seasonNumber {
                                    let seasonInfo = item
                                    if let images = seasonInfo["images"] as? [String : AnyObject] {
                                        if let posters = images["poster"] as? [String : String] {
                                            season.seasonLargeCoverImage = posters["full"]
                                            season.seasonMediumCoverImage = posters["medium"]
                                            season.seasonSmallCoverImage = posters["thumb"]
                                        }
                                    }
                                    seasons.append(season)
                                    break
                                }
                            }
                        }

                        let recipe = SeasonPickerRecipe(show: show, seasons: seasons)
                        Kitchen.serve(recipe: recipe)
                    }
                }
            }
        }


    }

    static func playMovie(pieces: [String]) {
        print(pieces.count)
        print(pieces)
        ["playMovie", "http://62.210.81.37/assets/images/movies/deadpool_2016/large-cover.jpg", "http://62.210.81.37/assets/images/movies/deadpool_2016/background.jpg", "Deadpool", "A former Special Forces operative turned mercenary is subjected to a rogue experiment that leaves him with accelerated healing powers, adopting the alter ego Deadpool.", "tt1431045", "quality=720p&hash=A1D0C3B0FD52A29D2487027E6B50F27EAF4912C5•quality=1080p&hash=6268ABCCB049444BEE76813177AA46643A7ADA88"]

        let torrentsString = pieces[5]
        if torrentsString == "" || torrentsString == "{{TORRENTS}}" {
            // NO torrents found
            Kitchen.serve(recipe: AlertRecipe(title: "No torrents found", description: "A torrent could not be found for \(pieces[3]).".cleaned, buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
            return
        }
        let allTorrents = torrentsString.componentsSeparatedByString("•")
        var torrents = [[String : String]]()
        for torrent in allTorrents {
            let components = torrent.componentsSeparatedByString("&")
            var torrentDict = [String : String]()
            for keyValuePair in components {
                let pairComponents = keyValuePair.componentsSeparatedByString("=")
                if let key = pairComponents.first, let value = pairComponents.last {
                    torrentDict[key] = value
                }
            }
            torrents.append(torrentDict)
        }

        torrents.sortInPlace({ $0["quality"] > $1["quality"] })

        var buttons = [AlertButton]()
        for torrent in torrents {
            buttons.append(AlertButton(title: torrent["quality"]!, actionID: "streamTorrent»\(torrent["hash"]!)»\(pieces[1])»\(pieces[2])»\(pieces[3].cleaned)»\(pieces[4].cleaned)»\(pieces[6])"))
        }

        Kitchen.serve(recipe: AlertRecipe(title: "Choose Quality", description: "Choose a quality to stream \(pieces[3])".cleaned, buttons: buttons, presentationType: .Modal))
    }

    static func streamTorrent(pieces: [String]) {
        // {{MAGNET}}:{{IMAGE}}:{{BACKGROUND_IMAGE}}:{{TITLE}}:{{SHORT_DESCRIPTION}}:{{TORRENTS}}

        Kitchen.dismissModal()
        let magnet = "magnet:?xt=urn:btih:\(pieces[1])&tr=" + Trackers.map { $0 }.joinWithSeparator("&tr=")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewControllerWithIdentifier("ProgressViewController") as? ProgressViewController {
            viewController.magnet = magnet
            viewController.imdbId = pieces[6]
            viewController.imageAddress = pieces[2]
            viewController.backgroundImageAddress = pieces[3]
            viewController.movieName = pieces[4]
            viewController.shortDescription = pieces[5]

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
        // ["addWatchlist", "tt1632701", "Suits", "show", "https://walter.trakt.us/images/shows/000/037/522/posters/original/0e6117705c.jpg", "https://walter.trakt.us/images/shows/000/037/522/fanarts/original/6ecdb75c1c.jpg", "247808", "suits"]
        // ["addWatchlist", "5093", "Risen", "movie", "http://62.210.81.37/assets/images/movies/risen_2016/large-cover.jpg", "http://62.210.81.37/assets/images/movies/risen_2016/background.jpg"]
//        print(pieces)
        let name = pieces[2]
        let id = pieces[1]
        let type = pieces[3]
        let cover = pieces[4]
        let fanart = pieces[5]
        var imdb = ""
        if pieces.indices.contains(6) {
            imdb = pieces[6]
        }
        var tvdb = ""
        if pieces.indices.contains(7) {
            tvdb = pieces[7]
        }
        var slugged = ""
        if pieces.indices.contains(8) {
            slugged = pieces[8]
        }

        WatchlistManager.sharedManager().itemExistsInWatchList(itemId: id, forType: ItemType(rawValue: type)!, completion: { exists in
            if exists {
                WatchlistManager.sharedManager().removeItemFromWatchList(WatchItem(name: name, id: id, coverImage: cover, fanartImage: fanart, type: type, imdbId: imdb, tvdbId: tvdb, slugged: slugged), completion: { removed in
                    if removed {
                        Kitchen.serve(recipe: AlertRecipe(title: "Removed", description: "\(name) was removed from your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    } else {
                        Kitchen.serve(recipe: AlertRecipe(title: "Not Found", description: "\(name) is not found in your watchlist.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                    }
                })
            } else {
                WatchlistManager.sharedManager().addItemToWatchList(WatchItem(name: name, id: id, coverImage: cover, fanartImage: fanart, type: type, imdbId: imdb, tvdbId: tvdb, slugged: slugged), completion: { added in
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
