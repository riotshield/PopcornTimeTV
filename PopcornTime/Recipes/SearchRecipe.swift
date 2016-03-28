//
//  SearchRecipe.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/19/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

class YIFYSearchRecipe: SearchRecipe {

    override init(type: PresentationType = .Search) {
        super.init(type: type)
    }

    override func filterSearchText(text: String, callback: (String -> Void)) {
        NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "720p", minimumRating: 0, queryTerm: text, genre: nil, sortBy: "download_count", orderBy: "desc") { movies, error in
            if let movies = movies {
                let mapped: [String] = movies.map { movie in
                    let torrent = movie.torrents.filter { $0.quality == "720p" }.first!

                    var string = "<lockup actionID=\"showMovie:\(movie.id)\" playActionID=\"playMovie:\(torrent.hash)\">"
                    string += "<img src=\"\(movie.parallaxPoster)\" width=\"250\" height=\"375\" />"
                    string += "<title style=\"tv-text-highlight-style: marquee-and-show-on-highlight;\">\(movie.title.cleaned)</title>"
                    string += "</lockup>"
                    return string
                }

                if let file = NSBundle.mainBundle().URLForResource("MovieSearchRecipe", withExtension: "xml") {
                    do {
                        var xml = try String(contentsOfURL: file)

                        xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: "Found \(movies.count) \(movies.count == 1 ? "movie" : "movies") for \"\(text.cleaned)\"")
                        xml = xml.stringByReplacingOccurrencesOfString("{{RESULTS}}", withString: mapped.joinWithSeparator("\n"))

                        callback(xml)
                    } catch {
                        print("Could not open Catalog template")
                    }
                }
            }
        }

    }

}
