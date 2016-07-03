//
//  ShowExtensions.swift
//  PopcornTime
//
//  Created by Tengis Batsaikhan on 5/05/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import PopcornKit

extension Show {

    var lockUp: String {
        var string = "<lockup actionID=\"showShow»\(id)»\(title.cleaned.slugged)»\(tvdbId)\" playActionID=\"showShow»\(id)»\(title.cleaned.slugged)»\(tvdbId)\">"
        string += "<img class=\"img\" src=\"\(posterImage)\" width=\"250\" height=\"375\" />"
        string += "<title style=\"tv-text-highlight-style: marquee-and-show-on-highlight;\">\(title.cleaned)</title>"
        string += "</lockup>"
        return string
    }

}
