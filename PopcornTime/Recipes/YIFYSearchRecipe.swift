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
                    var string = "<lockup actionID=\"showMovie»\(movie.id)\">"
                    string += "<img src=\"\(movie.mediumCoverImage)\" width=\"250\" height=\"375\" />"
                    string += "<title style=\"tv-text-highlight-style: marquee-and-show-on-highlight;\">\(movie.title.cleaned)</title>"
                    string += "</lockup>"
                    return string
                }

                if let file = NSBundle.mainBundle().URLForResource("SearchRecipe", withExtension: "xml") {
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

class EZTVSearchRecipe: SearchRecipe {

    var recipe: String? {
        if let file = NSBundle.mainBundle().URLForResource("SearchRecipe", withExtension: "xml") {
            do {
                return try String(contentsOfURL: file)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return nil
    }

    override init(type: PresentationType = .Search) {
        super.init(type: type)
    }

    override func filterSearchText(text: String, callback: (String -> Void)) {
        if let pageCount = NSUserDefaults.standardUserDefaults().objectForKey("EZTVPageCount") as? Int {
            var results = [Show]()
            let group = dispatch_group_create()
            for index in 0...pageCount {
                dispatch_group_enter(group)
                NetworkManager.sharedManager().searchEZTV(index, searchTerm: text) { shows, error in
                    if let shows = shows {
                        results += shows
                    }
                    dispatch_group_leave(group)
                }
            }

            dispatch_group_notify(group, dispatch_get_main_queue(), {
                let mapped: [String] = results.map { show in
                    var string = "<lockup actionID=\"showShow»\(show.id)»\(show.title.slugged)»\(show.tvdbId)\">"
                    string += "<img src=\"\(show.posterImage)\" width=\"250\" height=\"375\" />"
                    string += "<title style=\"tv-text-highlight-style: marquee-and-show-on-highlight;\">\(show.title.cleaned)</title>"
                    string += "</lockup>"
                    return string
                }
                if let recipe = self.recipe {
                    var xml = recipe
                    xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: "Found \(results.count) \(results.count == 1 ? "show" : "shows") for \"\(text.cleaned)\"")
                    xml = xml.stringByReplacingOccurrencesOfString("{{RESULTS}}", withString: mapped.joinWithSeparator("\n"))
                    callback(xml)
                }
            })
        }

    }
}
