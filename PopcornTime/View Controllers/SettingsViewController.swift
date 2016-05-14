//
//  SettingsViewController.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/18/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        self.settingsIcon.alpha = 0.25
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "TV Shows"
        case 1: return "Other"
            
        default: return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Theme Song Volume"
                if let volume = NSUserDefaults.standardUserDefaults().objectForKey("TVShowVolume") as? CGFloat {
                    cell.detailTextLabel?.text = "\(Int(volume * 100))%"
                } else {
                    cell.detailTextLabel?.text = "75%"
                }
                cell.accessoryType = .None
            }
            
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Clear All Cache"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .None
            }
            
        default: break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                // Log Out
                let alertController = UIAlertController(title: "TV Show Theme Song Volume", message: "Choose a volume for the TV Show theme songs", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Off", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setFloat(0.0, forKey: "TVShowVolume")
                    tableView.reloadData()
                }))
                
                alertController.addAction(UIAlertAction(title: "25%", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setFloat(0.25, forKey: "TVShowVolume")
                    tableView.reloadData()
                }))
                
                alertController.addAction(UIAlertAction(title: "50%", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setFloat(0.5, forKey: "TVShowVolume")
                    tableView.reloadData()
                }))
                
                alertController.addAction(UIAlertAction(title: "75%", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setFloat(0.75, forKey: "TVShowVolume")
                    tableView.reloadData()
                }))
                
                alertController.addAction(UIAlertAction(title: "100%", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setFloat(1.0, forKey: "TVShowVolume")
                    tableView.reloadData()
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            
        case 1:
            if indexPath.row == 0 {
                // TV Shows Theme
                let alertController = UIAlertController(title: "Clear Cache", message: "Clearing the cache will delete any unused images, incomplete torrent downloads and subtitles.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Clear Cache", style: .Destructive, handler: { action in
                    self.clearCache()
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        default: break
        }
    }
    
    func indexPathForPreferredFocusedViewInTableView(tableView: UITableView) -> NSIndexPath? {
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                self.settingsIcon.image = UIImage(named: "TV Shows")
            }
            
        case 1:
            if indexPath.row == 0 {
                self.settingsIcon.image = UIImage(named: "Cache")
            }
            
        default: self.settingsIcon.image = nil
        }
        return true
    }

    func clearCache() {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        if let cachcesDirectory = paths.first {
            do {
                let subs = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(cachcesDirectory)
                for item in subs {
                    try NSFileManager.defaultManager().removeItemAtPath(cachcesDirectory.stringByAppendingPathComponent(item))
                }
            } catch {
                
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
