//
//  WelcomeRecipe.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/26/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

public struct WelcomeRecipe: RecipeType {
    
    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Default
    
    let title: String
    let movies: [WatchItem]
    let shows: [WatchItem]
    
    init(title: String, movies: [WatchItem], shows: [WatchItem]) {
        self.title = title
        self.movies = movies
        self.shows = shows
    }
    
    init(title: String) {
        self.title = title
        self.movies = []
        self.shows = []
    }
    
    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }
    
    public var movieWatchList: String {
        let mapped: [String] = movies.map {
            var string = "<lockup actionID=\"showMovie»\($0.id)\">"
            string += "<img src=\"\($0.coverImage)\" width=\"250\" height=\"375\" />"
            string += "<title class=\"hover\">\($0.name.cleaned)</title>"
            string += "</lockup>"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }
    
    public var showWatchList: String {
        let mapped: [String] = shows.map {
            var string = "<lockup actionID=\"showMovie»\($0.id)\">"
            string += "<img src=\"\($0.coverImage)\" width=\"250\" height=\"375\" />"
            string += "<title class=\"hover\">\($0.name.cleaned)</title>"
            string += "</lockup>"
            return string
        }
        return mapped.joinWithSeparator("\n")
    }
    
    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("WelcomeRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{MOVIES_WATCHLIST}}", withString: movieWatchList)
                xml = xml.stringByReplacingOccurrencesOfString("{SHOWS_WATCHLIST}}", withString: showWatchList)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }
    
}