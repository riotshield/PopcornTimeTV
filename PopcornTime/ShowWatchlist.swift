//
//  ShowWatchlist.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen

struct ShowWatchlist: TabItem {

    let title = "Watchlist"

    func handler() {
        WatchlistManager.sharedManager().fetchWatchListItems(forType: .Show) { items in
            Kitchen.serve(recipe: ShowWatchlistRecipe(title: self.title, movies: items))
        }
    }

}
