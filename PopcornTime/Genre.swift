//
//  Popular.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 16/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit


struct Genre: TabItem {

    let title = "Genre"
    var fetchType: FetchType! = .Movies

    func handler() {
        let recipe = GenreRecipe.init(fetchType: fetchType)
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
