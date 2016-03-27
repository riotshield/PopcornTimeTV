//
//  MovieProductRecipe.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 13/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

public struct MovieProductRecipe: RecipeType {

    let movie: Movie
    let suggestions: [Movie]
    let existsInWatchList: Bool

    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Default

    public init(movie: Movie, suggestions: [Movie], existsInWatchList: Bool) {
        self.movie = movie
        self.suggestions = suggestions
        self.existsInWatchList = existsInWatchList
    }

    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }

    var directorsString: String {
        return movie.directors.map { "<text>\($0.name.cleaned)</text>" }.joinWithSeparator("")
    }

    var actorsString: String {
        return movie.actors.map { "<text>\($0.name.cleaned)</text>" }.joinWithSeparator("")
    }

    var genresString: String {
        if movie.genres.count == 2 {
            return "<text>\(movie.genres[0])</text>" + "/" + "<text>\(movie.genres[1])</text>"
        } else {
            return "<text>\(movie.genres.first!)</text>"
        }
    }

    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    var runtime: String {
        let (hours, minutes, _) = self.secondsToHoursMinutesSeconds(movie.runtime * 60)
        return "\(hours)h \(minutes)m"
    }

    var suggestionsString: String {
        let mapped: [String] = suggestions.map {
            var string = "<lockup actionID=\"showMovie:\($0.id)\">" + "\n"
            string += "<img src=\"\($0.parallaxPoster)\" width=\"150\" height=\"226\" />" + "\n"
            string += "<title>\($0.title.cleaned)</title>" + "\n"
            string += "</lockup>" + "\n"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }

    var castString: String {
        let mapped: [String] = movie.actors.map {
            let name = $0.name.componentsSeparatedByString(" ")
            var string = "<monogramLockup>" + "\n"
            string += "<monogram firstName=\"\(name.first!)\" lastName=\"\(name.last!)\"/>"
            string += "<title>\($0.name.cleaned)</title>" + "\n"
            string += "<subtitle>Actor</subtitle>" + "\n"
            string += "</monogramLockup>" + "\n"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }

    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("ProductRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{DIRECTORS}}", withString: directorsString)
                xml = xml.stringByReplacingOccurrencesOfString("{{ACTORS}}", withString: actorsString)
                var tomato = movie.tomatoesCriticsRating.lowercaseString
                if tomato == "none" {
                    xml = xml.stringByReplacingOccurrencesOfString("<text><badge src=\"resource://tomato-{{TOMATO_CRITIC_RATING}}\"/> {{TOMATO_CRITIC_SCORE}}%</text>", withString: "")
                } else if tomato == "rotten" {
                    tomato = "splat"
                }
                xml = xml.stringByReplacingOccurrencesOfString("{{TOMATO_CRITIC_RATING}}", withString: tomato)
                xml = xml.stringByReplacingOccurrencesOfString("{{TOMATO_CRITIC_SCORE}}", withString: String(movie.tomatoesCriticsScore))

                xml = xml.stringByReplacingOccurrencesOfString("{{RUNTIME}}", withString: runtime)
                xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: movie.title.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{GENRES}}", withString: genresString)
                xml = xml.stringByReplacingOccurrencesOfString("{{DESCRIPTION}}", withString: movie.descriptionFull.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{SHORT_DESCRIPTION}}", withString: movie.summary.cleaned)
                xml = xml.stringByReplacingOccurrencesOfString("{{IMAGE}}", withString: movie.largeCoverImage)
                xml = xml.stringByReplacingOccurrencesOfString("{{BACKGROUND_IMAGE}}", withString: movie.backgroundImage)
                xml = xml.stringByReplacingOccurrencesOfString("{{YEAR}}", withString: String(movie.year))
                xml = xml.stringByReplacingOccurrencesOfString("{{RATING}}", withString: movie.mpaRating.lowercaseString)

                xml = xml.stringByReplacingOccurrencesOfString("{{YOUTUBE_PREVIEW_URL}}", withString: movie.youtubeTrailerURL)
                xml = xml.stringByReplacingOccurrencesOfString("{{MAGNET}}", withString: movie.torrents.first!.hash)

                xml = xml.stringByReplacingOccurrencesOfString("{{SUGGESTIONS}}", withString: suggestionsString)

                xml = xml.stringByReplacingOccurrencesOfString("{{CAST}}", withString: castString)

                if existsInWatchList {
                    xml = xml.stringByReplacingOccurrencesOfString("{{WATCHLIST_ACTION}}", withString: "remove")
                } else {
                    xml = xml.stringByReplacingOccurrencesOfString("{{WATCHLIST_ACTION}}", withString: "add")
                }
                xml = xml.stringByReplacingOccurrencesOfString("{{MOVIE_ID}}", withString: String(movie.id))
                xml = xml.stringByReplacingOccurrencesOfString("{{TYPE}}", withString: "movie")
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }

}
