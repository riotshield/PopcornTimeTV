//
//  GenreRecipe.swift
//  PopcornTime
//
//  Created by Tengis Batsaikhan on 6/05/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

public struct GenreRecipe: RecipeType {

    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Tab
    var fetchType: FetchType! = .Movies

    let genres = [
        "Action",
        "Adventure",
        "Animation",
        "Biography",
        "Comedy",
        "Crime",
        "Documentary",
        "Drama",
        "Family",
        "Fantasy",
        "Film-Noir",
        "History",
        "Horror",
        "Music",
        "Musical",
        "Mystery",
        "Romance",
        "Sci-Fi",
        "Sport",
        "Thriller",
        "War",
        "Western"
    ]

    init(fetchType: FetchType = .Movies) {
        self.fetchType = fetchType
    }

    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }

    public var listItems: String {
        let mapped: [String] = genres.map {
            let string = "<listItemLockup sectionID=\"\($0)\">" +
                         "<title>\($0)</title>" +
                         "<relatedContent>" +
                         "<grid><section id=\"\($0)\"><activityIndicator /></section></grid>" +
                         "</relatedContent></listItemLockup>"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }

    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("GenreRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{LIST_ITEMS}}", withString: listItems)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }

    public func highlightSection(text: String, callback: (String -> Void)) {
        var data = ""
        let semaphore = dispatch_semaphore_create(0)
        switch self.fetchType! {
            case .Movies:
            NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "720p", minimumRating: 0, queryTerm: nil, genre: text, sortBy: "download_count", orderBy: "desc") { movies, error in
                if let movies = movies {
                    let mapped: [String] = movies.map { movie in
                        movie.lockUp
                    }
                    data = mapped.joinWithSeparator("\n")
                    dispatch_semaphore_signal(semaphore)
                }
            }
            case .Shows:
            let manager = NetworkManager.sharedManager()
            manager.fetchShowPageNumbers { pageNumbers, error in
                if let pageNumbers = pageNumbers {
                    manager.fetchShows(pageNumbers, searchTerm: nil, genre: text, sort: "trending", order: "1") { shows, error in
                        if let shows = shows {
                            let mapped: [String] = shows.map { show in
                                show.lockUp
                            }
                            data = mapped.joinWithSeparator("\n")
                            dispatch_semaphore_signal(semaphore)
                        }
                    }
                }
            }

        }

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        callback(data)
    }

}
