//
//  String+Cleaned.swift
//  PopcornTime
//
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import Foundation

extension String {

    var cleaned: String {
        var s = stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        s = s.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
        s = s.stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
        return s
    }
    
    var slugged: String {
        var s = stringByReplacingOccurrencesOfString(" ", withString: "-")
        s = s.stringByReplacingOccurrencesOfString(":", withString: "")
        return s.lowercaseString
    }

}
