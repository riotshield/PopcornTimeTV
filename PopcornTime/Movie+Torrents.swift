//
//  Movie+Torrents.swift
//  PopcornTime
//
//  Created by Tengis Batsaikhan on 25/06/2016.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import PopcornKit

extension Movie {

    var torrentsText: String {
        let filteredTorrents: [String] = torrents.map { torrent in
            return "quality=\(torrent.quality)&hash=\(torrent.hash)"
        }
        return filteredTorrents.joinWithSeparator("•")
    }
}
