//
//  WelcomeRecipe.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/26/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

struct PreviewItem {
    var fanartImage: String!
    
    init(fanartImage: String) {
        self.fanartImage = fanartImage
    }
}

public struct WelcomeRecipe: RecipeType {
    
    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Default
    
    let title: String
    let items: [PreviewItem]
    
    init(title: String, items: [PreviewItem]) {
        self.title = title
        self.items = items
    }
    
    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }
    
    public var topShowsAndMovies: String {
        let mapped: [String] = items.map {
            return "<img src=\"\($0.fanartImage)\"/>"
        }
        return mapped.joinWithSeparator("")
    }
    
    public var template: String {
        var xml = ""
        if let file = NSBundle.mainBundle().URLForResource("WelcomeRecipe", withExtension: "xml") {
            do {
                xml = try String(contentsOfURL: file)
                xml = xml.stringByReplacingOccurrencesOfString("{{TOP_SHOWS_MOVIES}}", withString: topShowsAndMovies)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return xml
    }
    
}


