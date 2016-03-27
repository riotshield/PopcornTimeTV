//
//  TabBarRecipe.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/26/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import Foundation
import TVMLKitchen

public struct TabBarRecipe: RecipeType {
    
    public let theme = DefaultTheme()
    public let presentationType = PresentationType.Modal
    
    public var items: [TabItem]
    
    public init(items: [TabItem]) {
        self.items = items
    }
    
    public var xmlString: String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
        xml += "<document>"
        xml += template
        xml += "</document>"
        return xml
    }
    
    public var template: String {
        let url = KitchenTabBar.bundle.URLForResource("KitchenTabBar", withExtension: "xml")!
        // swiftlint:disable:next force_try
        let xml = try! String(contentsOfURL: url)
        var string = ""
        for (index, item) in items.enumerate() {
            string += "<menuItem menuIndex=\"\(index)\">\n"
            string += "<title>\(item.title)</title>\n"
            string += "</menuItem>\n"
        }
        return xml.stringByReplacingOccurrencesOfString("{{menuItems}}", withString: string)
    }
    
}
