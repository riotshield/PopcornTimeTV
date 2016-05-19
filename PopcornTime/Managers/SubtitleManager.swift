//
//  SubtitleManager.swift
//  PopcornTime
//
//  Created by Yogi Bear on 5/13/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import Foundation
import Alamofire

@objc class SubtitleManager: NSObject, ZipKitDelegate {
    
    typealias CompletionBlock = ((name: String?, path: String?) -> Void)?
    
    var completion: CompletionBlock
    
    class func sharedManager() -> SubtitleManager {
        struct Struct {
            static let Instance = SubtitleManager()
        }
        
        return Struct.Instance
    }
    
    override init() {
        super.init()
        
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if let cachcesDirectory = paths.first {
            let path = cachcesDirectory.stringByAppendingPathComponent("Subtitles")
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                
            }
        }
    }
    
    @objc func fetchSubtitlesForIMDB(imdbID: String, completion: (([AnyObject]?) -> Void)?) {
        // Check if a sub exists
        if self.subtitlesExist(imdbID) {
            
        }
        
        // Clean up everything
        self.cleanSubs()
        
        
        let endpoint = "http://api.yifysubtitles.com/subs/\(imdbID)"
        
        let group = dispatch_group_create()
        
        Alamofire.request(.GET, endpoint)
        .responseJSON { response in
            var subtitleArray = [AnyObject]()
            if let response = response.result.value as? [String : AnyObject] {
                if let subs = response["subs"] as? [String : AnyObject] {
                    if let subtitles = subs[imdbID] as? [String : AnyObject] {
                        for (key, value) in subtitles {
                            if let items = value as? [AnyObject] {
                                if let first = items.first {
                                    if let url = first["url"] as? String {
                                        dispatch_group_enter(group)
                                        self.downloadSubtitle(imdbID, name: key.capitalizedString, url: "http://yifysubtitles.com\(url)") { name, path in
                                            if let name = name, let path = path {
                                                let dict = ["name": name, "path": path]
                                                subtitleArray.append(dict)
                                            }
                                            dispatch_group_leave(group)
                                        }
                                    }
                                }
                            }
                        }
                        
                        dispatch_group_notify(group, dispatch_get_main_queue(), { 
                            completion?(subtitleArray)
                        })
                    }
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    func downloadSubtitle(imdbId: String, name: String, url: String, completion: CompletionBlock) {
        self.completion = completion
        
        Alamofire.request(.GET, url)
        .responseData { response in
            if let data = response.data {
                let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                if let cachcesDirectory = paths.first {
                    let path = cachcesDirectory.stringByAppendingPathComponent("Subtitles").stringByAppendingPathComponent(imdbId).stringByAppendingPathComponent(url.lastPathComponent)
                    self.saveAndExpandSub(imdbId, name: name, path: path, data: data)
                } else {
                    self.completion?(name: nil, path: nil)
                }
            } else {
                self.completion?(name: nil, path: nil)
            }
        }
    }
    
    func saveAndExpandSub(imdbId: String, name: String, path: String, data: NSData) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            let pathComponent = path.lastPathComponent
            let newPath = path.stringByDeletingLastPathComponent.stringByAppendingPathComponent(path.lastPathComponent.stringByDeletingPathExtension).stringByAppendingPathComponent(pathComponent)
            try fileManager.createDirectoryAtPath(newPath.stringByDeletingLastPathComponent, withIntermediateDirectories: false, attributes: nil)
            try data.writeToFile(newPath, options: .DataWritingAtomic)
            let zip = ZKFileArchive(archivePath: newPath)
            if zip.inflateToDiskUsingResourceFork(false) == 1 {
                try fileManager.removeItemAtPath(newPath)
            }
            if let sub = try fileManager.contentsOfDirectoryAtPath(newPath.stringByDeletingLastPathComponent).first {
                if sub.pathExtension == "srt" {
                    self.completion?(name: name, path: newPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(sub))
                } else {
                    self.completion?(name: name, path: nil)
                }
            } else {
                self.completion?(name: nil, path: nil)
            }
        } catch {
            self.completion?(name: nil, path: nil)
        }
    }
    
    func cleanSubs() {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if let cachcesDirectory = paths.first {
            let path = cachcesDirectory.stringByAppendingPathComponent("Subtitles")
            do {
                let subs = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
                for item in subs {
                    try NSFileManager.defaultManager().removeItemAtPath(path.stringByAppendingPathComponent(item))
                }
            } catch {
                
            }
        }
    }
    
    func subtitlesExist(imdbId: String) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if let cachcesDirectory = paths.first {
            let path = cachcesDirectory.stringByAppendingPathComponent("Subtitles").stringByAppendingPathComponent(imdbId)
            
            var isDir: ObjCBool = false
            NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
            if isDir {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
}
