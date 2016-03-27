//
//  ShowProductRecipe.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 13/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

public struct DetailedEpisode {
    var episodeTitle: String!
    var episode: Episode!
    var fullScreenshot: String!
    var mediumScreenshot: String!
    var smallScreenshot: String!
    
    init() {
        
    }
}

public struct EpisodesProductRecipe: RecipeType {

    let show: Show
    let showInfo: ShowInfo
    let episodes: [Episode]
    let detailedEpisodes: [DetailedEpisode]

    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Default

    public init(show: Show, showInfo: ShowInfo, episodes: [Episode], detailedEpisodes: [DetailedEpisode]) {
        self.show = show
        self.showInfo = showInfo
        self.episodes = episodes
        self.detailedEpisodes = detailedEpisodes
    }

    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }

    var actorsString: String {
        return showInfo.cast.map { "<text>\($0.cleaned)</text>" }.joinWithSeparator("")
    }

    var genresString: String {
        if showInfo.genres.count == 3 {
            return "<text>\(showInfo.genres[0])</text>" + "/" + "<text>\(showInfo.genres[1])</text>" + "/" + "<text>\(showInfo.genres[2])</text>"
        } else if showInfo.genres.count == 2 {
            return "<text>\(showInfo.genres[0])</text>" + "/" + "<text>\(showInfo.genres[1])</text>"
        } else {
            return "<text>\(showInfo.genres.first!)</text>"
        }
    }

    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    var runtime: String {
        let (_, minutes, _) = self.secondsToHoursMinutesSeconds(showInfo.runtime * 60)
        return "\(minutes)m"
    }

    var episodesString: String {
        let mapped: [String] = detailedEpisodes.map {
            var string = "<lockup actionID=\"playEpisode:\(show.id):\($0.episode.season):\(show.title.slugged):\(show.tvdbId)\">" + "\n"
            string += "<img src=\"\($0.mediumScreenshot)\" width=\"300\" height=\"256\" />" + "\n"
            string += "<title>Season \($0.episodeTitle)</title>" + "\n"
            string += "</lockup>" + "\n"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }

    var castString: String {
        let mapped: [String] = showInfo.cast.map {
            let name = $0.componentsSeparatedByString(" ")
            var string = "<monogramLockup>" + "\n"
            string += "<monogram firstName=\"\(name.first!)\" lastName=\"\(name.last!)\"/>"
            string += "<title>\($0.cleaned)</title>" + "\n"
            string += "<subtitle>Actor</subtitle>" + "\n"
            string += "</monogramLockup>" + "\n"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }

    var firstEpisode: String {
        if let episode = episodes.first {
            if let hash = episode.torrents.first!.hash {
                return hash
            } else if let hash = episode.torrents.last!.hash {
                return hash
            }
        }
        return ""
    }
    
    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("ProductRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                // Remove Directors
                var directors = "            <info>\n"
                directors += "                <header>\n"
                directors += "                    <title>Directors</title>\n"
                directors += "                </header>\n"
                directors += "                {{DIRECTORS}}\n"
                directors += "            </info>\n"
                xml = xml.stringByReplacingOccurrencesOfString(directors, withString: "")
                
                xml = xml.stringByReplacingOccurrencesOfString("{{ACTORS}}", withString: actorsString)
                
                // Remove Tomatoes
                xml = xml.stringByReplacingOccurrencesOfString("<text><badge src=\"resource://tomato-{{TOMATO_CRITIC_RATING}}\"/> {{TOMATO_CRITIC_SCORE}}%</text>", withString: "")

                xml = xml.stringByReplacingOccurrencesOfString("{{RUNTIME}}", withString: runtime)
                xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: show.title.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{GENRES}}", withString: genresString)
                xml = xml.stringByReplacingOccurrencesOfString("{{DESCRIPTION}}", withString: show.synopsis.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{SHORT_DESCRIPTION}}", withString: show.synopsis.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{IMAGE}}", withString: show.posterImage)
                xml = xml.stringByReplacingOccurrencesOfString("{{BACKGROUND_IMAGE}}", withString: show.fanartImage)
                xml = xml.stringByReplacingOccurrencesOfString("{{YEAR}}", withString: "")
                xml = xml.stringByReplacingOccurrencesOfString("mpaa-{{RATING}}", withString: showInfo.contentRating.lowercaseString)

                var preview = "                <buttonLockup actionID=\"playPreview:{{YOUTUBE_PREVIEW_URL}}\">\n"
                preview += "                    <badge src=\"resource://button-preview\" />\n"
                preview += "                    <title>Trailer</title>\n"
                preview += "                </buttonLockup>\n"
                xml = xml.stringByReplacingOccurrencesOfString(preview, withString: "")
                
                xml = xml.stringByReplacingOccurrencesOfString("{{MAGNET}}", withString: firstEpisode)

                xml = xml.stringByReplacingOccurrencesOfString("{{SUGGESTIONS_TITLE}}", withString: "Episodes")
                xml = xml.stringByReplacingOccurrencesOfString("{{SUGGESTIONS}}", withString: episodesString)

                xml = xml.stringByReplacingOccurrencesOfString("{{CAST}}", withString: castString)

                var string = "                <buttonLockup actionID=\"addWatchlist:{{MOVIE_ID}}:{{TITLE}}:{{TYPE}}:{{IMAGE}}\">\n"
                string += "                    <badge src=\"resource://button-{{WATCHLIST_ACTION}}\" />\n"
                string += "                    <title>Watchlist</title>\n"
                string += "                </buttonLockup>\n"
                xml = xml.stringByReplacingOccurrencesOfString(string, withString: "")
                
                xml = xml.stringByReplacingOccurrencesOfString("{{MOVIE_ID}}", withString: "")
                xml = xml.stringByReplacingOccurrencesOfString("{{TYPE}}", withString: "movie")
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }

}
