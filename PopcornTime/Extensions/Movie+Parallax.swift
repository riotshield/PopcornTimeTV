//
//  Movie+Parallax.swift
//  PopcornTime
//
//  Created by Joe Bloggs on 26/03/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import PopcornKit

extension Movie {

    var parallaxPoster: String {
        let queryString = "title=\(title)&year=\(year)&fallback=\(mediumCoverImage)"
            .stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            .stringByReplacingOccurrencesOfString("&", withString: "&amp;")

        return "https://lsrdb.com/search?\(queryString)"
    }

}
