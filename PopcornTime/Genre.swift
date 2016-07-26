//
//  Genre.swift
//  PopcornTime
//
//  Created by RefusedFlow on 24/07/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

struct Genre: TabItem {

    var title = "Genre"

    var fetchType: FetchType! = .Movies {
        didSet {
            if let _ = self.fetchType {
                switch self.fetchType! {
                case .Movies: title = "Genre"
                case .Shows: title = "Genre"

                }
            }
        }
    }

    func handler() {
        switch self.fetchType! {
        case .Movies:
            NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "1080p", minimumRating: 3, queryTerm: nil, genre: nil, sortBy: "seeds", orderBy: "desc") { movies, error in
                if movies != nil {
                    let recipe = GenreRecipe(fetchType: self.fetchType)
                    self.serveRecipe(recipe)
                }
            }
        case .Shows:
            let manager = NetworkManager.sharedManager()
            manager.fetchShowPageNumbers { pageNumbers, error in
                if let _ = pageNumbers {
                    // this is temporary limit until solve pagination
                    manager.fetchShows([1], sort: "trending") { shows, error in
                        if shows != nil {
                            let recipe = GenreRecipe(fetchType: self.fetchType)
                            self.serveRecipe(recipe)
                        }
                    }
                }
            }
        }
    }


    func serveRecipe(recipe: GenreRecipe) {
        Kitchen.appController.evaluateInJavaScriptContext({jsContext in
            let highlightSection: @convention(block) (String, JSValue) -> () = {(text, callback) in
                recipe.highlightSection(text) { string in
                    if callback.isObject {
                        callback.callWithArguments([string])
                    }
                }
            }

            jsContext.setObject(unsafeBitCast(highlightSection, AnyObject.self), forKeyedSubscript: "highlightSection")

            if let file = NSBundle.mainBundle().URLForResource("Genre", withExtension: "js") {
                do {
                    var js = try String(contentsOfURL: file)
                    js = js.stringByReplacingOccurrencesOfString("{{RECIPE}}", withString: recipe.xmlString)
                    jsContext.evaluateScript(js)
                } catch {
                    print("Could not open Genre.js")
                }
            }

            }, completion: nil)
    }
}
