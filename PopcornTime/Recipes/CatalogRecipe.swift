//
//  CatalogRecipe.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 15/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

public struct CatalogRecipe: RecipeType {

    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Tab

    let title: String
    let movies: [Movie]!
    let shows: [Show]!

    init(title: String, movies: [Movie]? = nil, shows: [Show]? = nil) {
        self.title = title
        self.movies = movies
        self.shows = shows
    }

    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }

    public var movieString: String {
        if let movies = self.movies {
            let mapped: [String] = movies.map {
                $0.lockUp
            }
            return mapped.joinWithSeparator("")
        } else {
            let mapped: [String] = shows.map {
                $0.lockUp
            }
            return mapped.joinWithSeparator("")
        }
    }

    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("CatalogRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: title)
                xml = xml.stringByReplacingOccurrencesOfString("{{POSTERS}}", withString: movieString)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }

}
