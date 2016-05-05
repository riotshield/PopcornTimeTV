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
        var string = "<lockup actionID=\"showShow»\(id)»\(title.slugged)»\(tvdbId)\">"
        string += "<img src=\"\(posterImage)\" width=\"250\" height=\"375\" />"
        string += "<title class=\"hover\">\(title.cleaned)</title>"
        string += "</lockup>"
        return string
    }

}
