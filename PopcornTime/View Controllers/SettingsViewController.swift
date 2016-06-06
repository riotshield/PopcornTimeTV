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

        self.tableView.contentInset = UIEdgeInsets(top: 100, left: -50, bottom: 0, right: 0)
        self.settingsIcon.image = UIImage(named: "settings.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 1
        }
        if section == 2 {
            return 2
        }
        if section == 3 {
            return 1
        }
        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "TV Shows"
        case 1: return "Other"
        case 2: return "Player"
        case 3: return "Web Server"
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

        case 2:
            let settings = SQSubSetting.loadFromDisk()
            if indexPath.row == 0 {
                cell.textLabel?.text = "Font Size"
                if settings.sizeFloat == 20.0 {
                    cell.detailTextLabel?.text = "Small"
                } else if settings.sizeFloat == 25.0 {
                    cell.detailTextLabel?.text = "Medium"
                } else if settings.sizeFloat == 30.0 {
                        cell.detailTextLabel?.text = "Medium Large"
                } else if settings.sizeFloat == 45.0 {
                    cell.detailTextLabel?.text = "Large"
                }
                cell.accessoryType = .None
            }
            /*
             if indexPath.row == 1 {
                 cell.textLabel?.text = "Font Name"
                 cell.detailTextLabel?.text = settings.fontName
                 cell.accessoryType = .None
             }
             */
            if indexPath.row == 1 {
                cell.textLabel?.text = "Subtitle Background"
                if let backgroundType = settings.backgroundType {
                    switch backgroundType {
                    case .Blur: cell.detailTextLabel?.text = "Blur"
                    case .Black: cell.detailTextLabel?.text = "Black"
                    case .White: cell.detailTextLabel?.text = "White"
                    case .None: cell.detailTextLabel?.text = "None"
                    }
                }
                cell.accessoryType = .None
            }
        case 3:
            cell.textLabel?.text = "Start"
            if let startWebServer = NSUserDefaults.standardUserDefaults().objectForKey("StartWebServer") as? Bool {
                cell.detailTextLabel?.text = startWebServer.boolValue ? "Yes" : "No"
            } else {
                cell.detailTextLabel?.text = "No"
            }
            cell.accessoryType = .None
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

        case 2:
            if let settings = SQSubSetting.loadFromDisk() as? SQSubSetting {
                if indexPath.row == 0 {
                    let alertController = UIAlertController(title: "Subtitle Font Size", message: "Choose a font size for subtitles.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Small (20pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 20.0
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "Medium (25pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 25.0
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "Medium Large (30pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 30.0
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "Large (45pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 45.0
                        settings.writeToDisk()
                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }

                if indexPath.row == 1 {
                    let alertController = UIAlertController(title: "Subtitle Background", message: "Choose a background for the subtitles.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Blur", style: .Default, handler: { action in
                        settings.backgroundType = .Blur
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "Black", style: .Default, handler: { action in
                        settings.backgroundType = .Black
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "White", style: .Default, handler: { action in
                        settings.backgroundType = .White
                        settings.writeToDisk()
                    }))

                    alertController.addAction(UIAlertAction(title: "None", style: .Default, handler: { action in
                        settings.backgroundType = .None
                        settings.writeToDisk()

                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        case 3:
            if indexPath.row == 0 {
                var ip = WebServerManager.sharedManager().getWiFiAddress()
                if ip == nil {
                    ip = WebServerManager.sharedManager().getLANAddress()
                }
                let alertController = UIAlertController(title: "Start Web Sever", message: "Starts a web server that allows you to browse to PopcornTimeTV from any browser http://\(ip!):8181 and view the downloaded media.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "StartWebServer")
                    WebServerManager.sharedManager().startServer(8181)
                    tableView.reloadData()
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "StartWebServer")
                    WebServerManager.sharedManager().stopServer()
                    tableView.reloadData()
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
//                self.settingsIcon.image = UIImage(named: "settings_tvshows.png")
            }

        case 1:
            if indexPath.row == 0 {
//                self.settingsIcon.image = UIImage(named: "settings_cache.png")
            }

        default: self.settingsIcon.image = UIImage(named: "settings.png")
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
