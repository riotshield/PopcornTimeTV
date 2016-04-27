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

    func handler() {
        NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "1080p", minimumRating: 0, queryTerm: nil, genre: nil, sortBy: "date_added", orderBy: "desc") { movies, error in
            if let movies = movies {
                let recipe = CatalogRecipe(title: "Latest Movies", movies: movies)
                Kitchen.serve(recipe: recipe)
            }
        }
    }

}
