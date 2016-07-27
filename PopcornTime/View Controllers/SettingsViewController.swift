

import UIKit
import PopcornKit
import TVMLKitchen

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsIcon: UIImageView!

    let version: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    let build: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String

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
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 2
        }
        if section == 2 {
            return 4
        }
        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "TV Shows"
        case 1: return "Player"
        case 2: return "Other"
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
            let settings = SQSubSetting.loadFromDisk()
            if indexPath.row == 0 {
                cell.textLabel?.text = "Font Size"
                if settings.sizeFloat == 46.0 {
                    cell.detailTextLabel?.text = "Small"
                } else if settings.sizeFloat == 56.0 {
                    cell.detailTextLabel?.text = "Medium"
                } else if settings.sizeFloat == 66.0 {
                    cell.detailTextLabel?.text = "Medium Large"
                } else if settings.sizeFloat == 96.0 {
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

        case 2:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Clear All Cache"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .None
            }

            if indexPath.row == 1 {
                cell.textLabel?.text = "Kick Ass Search"
                if let katSearch = NSUserDefaults.standardUserDefaults().objectForKey("KATSearch") as? Bool {
                    cell.detailTextLabel?.text = katSearch.boolValue ? "Yes" : "No"
                } else {
                    cell.detailTextLabel?.text = "No"
                }
                cell.accessoryType = .None
            }

            if indexPath.row == 2 {
                cell.textLabel?.text = "Start web server"
                if let startWebServer = NSUserDefaults.standardUserDefaults().objectForKey("StartWebServer") as? Bool {
                    cell.detailTextLabel?.text = startWebServer.boolValue ? "Yes" : "No"
                } else {
                    cell.detailTextLabel?.text = "No"
                }
                cell.accessoryType = .None
            }

            if indexPath.row == 3 {
                cell.textLabel?.text = "Version"
                cell.detailTextLabel?.text = "\(version) (\(build))"
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
            if let settings = SQSubSetting.loadFromDisk() as? SQSubSetting {
                if indexPath.row == 0 {
                    let alertController = UIAlertController(title: "Subtitle Font Size", message: "Choose a font size for subtitles.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Small (46pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 46.0
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "Medium (56pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 56.0
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "Medium Large (66pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 66.0
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "Large (96pts)", style: .Default, handler: { action in
                        settings.sizeFloat = 96.0
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }

                if indexPath.row == 1 {
                    let alertController = UIAlertController(title: "Subtitle Background", message: "Choose a background for the subtitles.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Blur", style: .Default, handler: { action in
                        settings.backgroundType = .Blur
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "Black", style: .Default, handler: { action in
                        settings.backgroundType = .Black
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "White", style: .Default, handler: { action in
                        settings.backgroundType = .White
                        settings.writeToDisk()
                        tableView.reloadData()
                    }))

                    alertController.addAction(UIAlertAction(title: "None", style: .Default, handler: { action in
                        settings.backgroundType = .None
                        settings.writeToDisk()
                        tableView.reloadData()

                    }))

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }

        case 2:
            if indexPath.row == 0 {
                // TV Shows Theme
                let alertController = UIAlertController(title: "Clear Cache", message: "Clearing the cache will delete any unused images, incomplete torrent downloads and subtitles.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Clear Cache", style: .Destructive, handler: { action in
                    self.clearCache()
                }))

                self.presentViewController(alertController, animated: true, completion: nil)
            }

            if indexPath.row == 1 {
                let alertController = UIAlertController(title: "Kick Ass Torrent Search", message: "Activate Kick Ass torrent search that allows you search movies & tv shows from \"kat.cr\". You must restart application to apply this setting.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "KATSearch")
                    tableView.reloadData()
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { action in
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "KATSearch")
                    tableView.reloadData()
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }

            if indexPath.row == 2 {
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

            if indexPath.row == 3 {
                UpdateManager.sharedManager().checkForUpdates(forVersion: version) { (updateAvailable, name, releaseNotes, error) in
                    if updateAvailable {
                        let alertController = UIAlertController(title: "Update Available", message: "A new version of PopcornTime is available.\n\(name!)\n\n\(releaseNotes!)\n\nVisit https://github.com/PopcornTimeTV/PopcornTimeTV to update.", preferredStyle: .Alert)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        alertController.addAction(UIAlertAction(title: nil, style: .Cancel, handler: nil))
                    } else {
                        let alertController = UIAlertController(title: "No Updates Available", message: "You are using the latest version, \(self.version), however, if you are a developer, there might be a minor update avaible as a commit, you are using commit \(self.build), check https://github.com/PopcornTimeTV/PopcornTimeTV to see if new commits are available.", preferredStyle: .Alert)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        alertController.addAction(UIAlertAction(title: nil, style: .Cancel, handler: nil))
                    }
                }
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
