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

    func handler() {
        let recipe = GenreRecipe()
        Kitchen.appController.evaluateInJavaScriptContext({jsContext in
            let highlightSection: @convention(block) (String, JSValue) -> () = {(text, callback) in
                    recipe.highlightSection(text) { string in
                        if callback.isObject {
                            callback.callWithArguments([string])
                        }
                    }
            }

            jsContext.setObject(unsafeBitCast(highlightSection, AnyObject.self), forKeyedSubscript: "highlightSection")
            let event = "var doc = makeDocument(`\(recipe.xmlString)`);" +
                        "var highlightSectionEvent = function(event) {" +
                        "   var ele = event.target, " +
                        "             sectionID = ele.getAttribute('sectionID'); " +
                        "   if(sectionID){ " +
                        "       var container = doc.getElementById(sectionID);" +
                        "       var titleTag = doc.getElementById('title');" +
                        "       highlightSection(sectionID, function(data) { " +
                        "           container.innerHTML = data;" +
                        "           titleTag.innerHTML = sectionID;" +
                        "       }); " +
                        "       return; " +
                        "    } " +
                        "};"
            let js = "var listItemLockupElements = doc.getElementsByTagName(\"listItemLockup\");" +
                     "for (var i = 0; i < listItemLockupElements.length; i++) { " +
                     "  listItemLockupElements.item(i).addEventListener(\"highlight\", highlightSectionEvent.bind(this));" +
                     "}"


            jsContext.evaluateScript(event + js)
            jsContext.evaluateScript("menuBarItemPresenter(doc);")
            }, completion: nil)
   }
}
