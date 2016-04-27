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

    let title = "Popular"

    var fetchType: FetchType! = .Movies

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
            NetworkManager.sharedManager().fetchShowsForPage(1) { shows, error in
                if let shows = shows {
                    let recipe = CatalogRecipe(title: "Popular TV Shows", shows: shows)
                    Kitchen.serve(recipe: recipe)
                }
            }
        }
    }

}
