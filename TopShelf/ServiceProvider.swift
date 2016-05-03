//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Tengis Batsaikhan on 27/04/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import Foundation
import TVServices
import PopcornKit

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
    }
    
    var items: [TVContentItem] = []

    var topShelfItems: [TVContentItem] {
        let manager = NetworkManager.sharedManager()
        
        let semaphore = dispatch_semaphore_create(0)
        
        manager.fetchServers { servers, error in
            if let servers = servers {
                if let yts = servers["yts"] as? [String], let eztv = servers["eztv"] as? [String] {
                    manager.setServerEndpoints(yts: yts.first!, eztv: eztv.first!)
                    
                    manager.fetchShowsForPage(1) { shows, error in

                        if let shows = shows {
                            var ShowItems = [TVContentItem]();
                            manager.fetchMovies(limit: 10, page: 1, quality: "1080p", minimumRating: 3, queryTerm: nil, genre: nil, sortBy: "seeds", orderBy: "desc", withImages: true) { movies, error in
                                if let movies = movies {
                                    var MovieItems = [TVContentItem]();

                                    for movie in movies {
                                        MovieItems.append(
                                            self.buildShelfItem(
                                                movie.title.cleaned,
                                                Image: movie.mediumCoverImage,
                                                Action: "showMovie/\(String(movie.id))"
                                            )
                                        )
                                    }
                                  
                                    let latestMoviesSectionTitle = "Latest Movies"
                                    let latestMovieSectionItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: latestMoviesSectionTitle, container: nil)!)
                                    latestMovieSectionItem!.title = latestMoviesSectionTitle
                                    latestMovieSectionItem!.topShelfItems = MovieItems

                                    self.items.append(latestMovieSectionItem!)

                                }
                                
                                for show in shows[0..<10] {
                                    ShowItems.append(
                                        self.buildShelfItem(
                                            show.title.cleaned,
                                            Image: show.posterImage,
                                            Action:  "showShow/\(show.id)/\(show.title.slugged)/\(show.tvdbId)"
                                        )
                                    )
                                }
                              
                                let popularShowsSectionTitle = "Popular Shows"
                                let popularShowSectionItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: popularShowsSectionTitle, container: nil)!)
                                popularShowSectionItem!.title = popularShowsSectionTitle
                                popularShowSectionItem!.topShelfItems = ShowItems
                                
                                self.items.append(popularShowSectionItem!)
                                
                                dispatch_semaphore_signal(semaphore)
                            }
                        }
                    }
                }
            }
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return self.items
    }
    
    func buildShelfItem(Title: String, Image: String, Action: String) -> TVContentItem
    {
        let item = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: Title, container: nil)!)
        item!.imageURL = NSURL(string:Image)
        item!.imageShape = .Poster
        item!.displayURL = NSURL(string: "PopcornTimeTV://\(Action)");
        item!.playURL = NSURL(string: "PopcornTimeTV://\(Action)");
        item!.title = Title
        return item!
    }

}

