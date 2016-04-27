//
//  Search.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen

struct Search: TabItem {

    let title = "Search"

    var fetchType: FetchType! = .Movies

    func handler() {
        switch self.fetchType! {
        case .Movies:
            Kitchen.serve(recipe: YIFYSearchRecipe(type: .TabSearch))

        case .Shows:
            Kitchen.serve(recipe: EZTVSearchRecipe(type: .TabSearch))
        }
    }

}
