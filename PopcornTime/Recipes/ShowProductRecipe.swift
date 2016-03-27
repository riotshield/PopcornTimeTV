//
//  ShowProductRecipe.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 13/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit
import SWXMLHash

public struct Season {
    public var seasonNumber: Int!
    public var seasonId: String!
    public var episodes: [Episode]!
    public var seasonLargeCoverImage: String!
    public var seasonMediumCoverImage: String!
    public var seasonSmallCoverImage: String!
    
    public init() {
        
    }
}

public struct ShowInfo {
    
    public var airDay: String!
    public var airTime: String
    public var contentRating: String!
    
    public var cast: [String]!
    public var genres: [String]!
    
    public var network: String!
    
    public var runtime: Int!
    
    public init(xml: XMLIndexer) {
        let seriesInfo = xml["Data"]["Series"]
        
        self.airDay = seriesInfo["Airs_DayOfWeek"].element!.text!
        self.airTime = seriesInfo["Airs_Time"].element!.text!
        
        self.contentRating = seriesInfo["ContentRating"].element!.text!
        
        self.cast = seriesInfo["Actors"].element!.text!.componentsSeparatedByString("|")
        self.cast.removeAtIndex(self.cast.count - 1)
        self.cast.removeAtIndex(0)
        
        self.genres = seriesInfo["Genre"].element!.text!.componentsSeparatedByString("|")
        self.genres.removeAtIndex(self.genres.count - 1)
        self.genres.removeAtIndex(0)
        
        self.network = seriesInfo["Network"].element!.text!
        
        self.runtime = Int(seriesInfo["Runtime"].element!.text!)
    }
}

public struct ShowProductRecipe: RecipeType {

    let show: Show
    let showInfo: ShowInfo
    let seasons: [Season]
    let existsInWatchList: Bool

    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Default

    public init(show: Show, showInfo: ShowInfo, seasons: [Season], existsInWatchList: Bool) {
        self.show = show
        self.showInfo = showInfo
        self.seasons = seasons.sort({ $0.seasonNumber < $1.seasonNumber })
        self.existsInWatchList = existsInWatchList
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
            return "<text>\(showInfo.genres[0])" + "/" + "\(showInfo.genres[1])" + "/" + "\(showInfo.genres[2])</text>"
        } else if showInfo.genres.count == 2 {
            return "<text>\(showInfo.genres[0])" + "/" + "\(showInfo.genres[1])</text>"
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

    var seasonsString: String {
        let mapped: [String] = seasons.map {
            var string = "<lockup actionID=\"showSeason:\(show.id):\($0.seasonNumber):\(show.title.slugged):\(show.tvdbId)\">" + "\n"
            string += "<img src=\"\($0.seasonMediumCoverImage)\" width=\"150\" height=\"226\" />" + "\n"
            string += "<title>Season \($0.seasonNumber)</title>" + "\n"
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
        let season = seasons.first!
        for episode in season.episodes {
            if episode.season == 1 && episode.episode == 1 {
                if let hash = episode.torrents.first!.hash {
                    return hash
                } else if let hash = episode.torrents.last!.hash {
                    return hash
                }
            }
        }
        
        return ""
    }
    
    var previewButton: String {
        var preview = "<buttonLockup actionID=\"playPreview:{{YOUTUBE_PREVIEW_URL}}\">\n"
        preview += "<badge src=\"resource://button-preview\" />\n"
        preview += "<title>Trailer</title>\n"
        preview += "</buttonLockup>\n"
        return preview
    }
    
    var watchlistButton: String {
        var string = "<buttonLockup actionID=\"addWatchlist:\(show.id):\(show.title):show:\(show.posterImage)\">\n"
        string += "<badge src=\"resource://button-{{WATCHLIST_ACTION}}\" />\n"
        string += "<title>Watchlist</title>\n"
        string += "</buttonLockup>"
        return string
    }
    
    var themeSong: String {
        var s = "<background>\n"
        s += "<audio>\n"
        s += "<asset id=\"tv_theme\" src=\"http://tvthemes.plexapp.com/\(show.tvdbId).mp3\"/>"
        s += "</audio>\n"
        s += "</background>\n"
        return s
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
                xml = xml.stringByReplacingOccurrencesOfString("{{AIR_DATE_TIME}}", withString: "<text>\(showInfo.airDay)'s \(showInfo.airTime)</text>")
                
                var string = "                <buttonLockup actionID=\"playPreview:{{YOUTUBE_PREVIEW_URL}}\">\n"
                string += "                    <badge src=\"resource://button-preview\" />\n"
                string += "                    <title>Trailer</title>\n"
                string += "                </buttonLockup>\n"
                xml = xml.stringByReplacingOccurrencesOfString(string, withString: "")
                
                xml = xml.stringByReplacingOccurrencesOfString("{{MAGNET}}", withString: firstEpisode)

                xml = xml.stringByReplacingOccurrencesOfString("{{SUGGESTIONS_TITLE}}", withString: "Seasons")
                xml = xml.stringByReplacingOccurrencesOfString("{{SUGGESTIONS}}", withString: seasonsString)

                xml = xml.stringByReplacingOccurrencesOfString("{{CAST}}", withString: castString)

                xml = xml.stringByReplacingOccurrencesOfString("{{WATCH_LIST_BUTTON}}", withString: watchlistButton)
                if existsInWatchList {
                    xml = xml.stringByReplacingOccurrencesOfString("{{WATCHLIST_ACTION}}", withString: "remove")
                } else {
                    xml = xml.stringByReplacingOccurrencesOfString("{{WATCHLIST_ACTION}}", withString: "add")
                }
                
                xml = xml.stringByReplacingOccurrencesOfString("{{THEME_SONG}}", withString: themeSong)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }

}
