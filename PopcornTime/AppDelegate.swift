//
//  AppDelegate.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 15/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import UIKit
import TVMLKitchen
import PopcornKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let cookbook = Cookbook(launchOptions: launchOptions)
        cookbook.actionIDHandler = ActionHandler.primary
        cookbook.playActionIDHandler = ActionHandler.play

        cookbook.evaluateAppJavaScriptInContext = { appController, context in

        }

        Kitchen.prepare(cookbook)

        let manager = NetworkManager.sharedManager()
        manager.fetchServers { servers, error in
            if let servers = servers {
                if let yts = servers["yts"] as? [String], let eztv = servers["eztv"] as? [String] {
                    manager.setServerEndpoints(yts: yts.first!, eztv: eztv.first!)

                    manager.fetchShowsForPage(1) { shows, error in
                        if let shows = shows {
                            manager.fetchMovies(limit: 5, page: 1, quality: "1080p", minimumRating: 3, queryTerm: nil, genre: nil, sortBy: "seeds", orderBy: "desc", withImages: true) { movies, error in
                                if let movies = movies {
                                    var previewItems = [PreviewItem]()

                                    // Syft through Movies
                                    for (index, item) in shows.enumerate() {
                                        if index == 5 {
                                            break
                                        }

                                        previewItems.append(PreviewItem(fanartImage: item.fanartImage))
                                    }

                                    // Syft through TV Shows
                                    for movie in movies {
                                        previewItems.append(PreviewItem(fanartImage: movie.backgroundImage))
                                    }

                                    Kitchen.serve(recipe: WelcomeRecipe(title: "PopcornTime", items: previewItems))
                                    
                                    self.checkForUpdates()
                                }
                            }
                        }
                    }
                }
            }
        }

        return true
    }
    
    func checkForUpdates() {
        if let currentVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            UpdateManager.sharedManager().checkForUpdates(forVersion: currentVersion) { (updateAvailable, name, releaseNotes, error) in
                if updateAvailable {
                    Kitchen.serve(recipe: AlertRecipe(title: "Update Available", description: "A new version of PopcornTime is available.\n\(name!)\n\n\(releaseNotes!)\n\nVisit https://github.com/PopcornTimeTV/PopcornTimeTV to update.", buttons: [AlertButton(title: "Okay", actionID: "closeAlert")], presentationType: .Modal))
                }
            }
        }
    }
}
