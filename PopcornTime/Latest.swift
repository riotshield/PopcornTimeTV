//
//  Latest.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

struct Latest: TabItem {

    let title = "Latest"
    var fetchType: FetchType! = .Movies

    func handler() {
        switch self.fetchType! {
        case .Movies:
            NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "1080p", minimumRating: 0, queryTerm: nil, genre: nil, sortBy: "date_added", orderBy: "desc") { movies, error in
                if let movies = movies {
                    let recipe = CatalogRecipe(title: "Latest Movies", movies: movies)
                    Kitchen.serve(recipe: recipe)
                }
            }
        case .Shows:
            let manager = NetworkManager.sharedManager()
            manager.fetchShowPageNumbers { pageNumbers, error in
                if let _ = pageNumbers {
                    // this is temporary limit until solve pagination
                    manager.fetchShows([1, 2, 3, 4, 5, 6, 6, 8, 9, 10], sort: "updated") { shows, error in
                        if let shows = shows {
                            let recipe = CatalogRecipe(title: "Recently Updated", shows: shows.sort({ show1, show2 -> Bool in
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
