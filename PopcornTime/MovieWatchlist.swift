//
//  MovieWatchlist.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen

struct MovieWatchlist: TabItem {

    let title = "Watchlist"

    func handler() {
        WatchlistManager.sharedManager().fetchWatchListItems(forType: .Movie) { items in
            Kitchen.serve(recipe: MovieWatchlistRecipe(title: self.title, movies: items))
        }
    }

}
