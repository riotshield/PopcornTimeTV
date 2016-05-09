//
//  Popular.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

enum FetchType {
    case Movies
    case Shows
}

struct Popular: TabItem {

    var title = "Popular"

    var fetchType: FetchType! = .Movies {
        didSet {
            if let _ = self.fetchType {
                switch self.fetchType! {
                case .Movies: title = "Popular"
                case .Shows: title = "Recently Updated"
                    
                }
            }
        }
    }

    func handler() {
        switch self.fetchType! {
        case .Movies:
            NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "1080p", minimumRating: 3, queryTerm: nil, genre: nil, sortBy: "seeds", orderBy: "desc") { movies, error in
                if let movies = movies {
                    let recipe = CatalogRecipe(title: "Popular Movies", movies: movies)
                    Kitchen.serve(recipe: recipe)
                }
            }

        case .Shows:
            let manager = NetworkManager.sharedManager()
            manager.fetchShowPageNumbers { pageNumbers, error in
                if let pageNumbers = pageNumbers {
                    manager.fetchLatestEZTVShows(pageNumbers) { shows, error in
                        if let shows = shows {
                            let recipe = CatalogRecipe(title: "Latest TV Shows", shows: shows.sort({ show1, show2 -> Bool in
                                if let date1 = show1.lastUpdated, let date2 = show2.lastUpdated {
                                    return date1 < date2
                                }
                                return true
                            }))
                            Kitchen.serve(recipe: recipe)
                        }
                    }
                }
            }
        }
    }

}
