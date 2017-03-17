/* This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Storage

class MigrateData: NSObject {
    
    private var files: FileAccessor!
    private var db: COpaquePointer = nil
    
    // TODO: WIP:
    // Detect old db type.
    // Migrate one object type at a time.
    // Save to coredata.
    // Remove old db.
    
    enum ProcessOrder: Int {
        case Bookmarks = 0
        case History = 1
        case Domains = 2
        case Favicons = 3
        case Tabs = 4
        case Delete = 5
    }
    var completedCalls: [ProcessOrder: Bool] = [.Bookmarks: false, .History: false, .Domains: false, .Favicons: false, .Tabs: false] {
        didSet {
            checkCompleted()
        }
    }
    var completedCallback: ((success: Bool) -> Void)?
    
    required convenience init(completed: ((success: Bool) -> Void)?) {
        self.init()
        self.files = ProfileFileAccessor(localName: "profile")
        
        completedCallback = completed
        process()
    }
    
    override init() {
        super.init()
    }
    
    private func process() {
        if hasOldDb() {
            debugPrint("Found old database...")
            
            migrateBookmarks { (success) in
                debugPrint("Migrate bookmarks... \(success ? "Done" : "Failed")")
                self.completedCalls[ProcessOrder.Bookmarks] = success
            }
            migrateHistory { (success) in
                debugPrint("Migrate history... \(success ? "Done" : "Failed")")
                self.completedCalls[ProcessOrder.History] = success
            }
            migrateDomainData { (success) in
                debugPrint("Migrate domains... \(success ? "Done" : "Failed")")
                self.completedCalls[ProcessOrder.Domains] = success
            }
            migrateFavicons { (success) in
                debugPrint("Migrate favicons... \(success ? "Done" : "Failed")")
                self.completedCalls[ProcessOrder.Favicons] = success
            }
            migrateTabs { (success) in
                debugPrint("Migrate tabs... \(success ? "Done" : "Failed")")
                self.completedCalls[ProcessOrder.Tabs] = success
            }
        }
    }
    
    private func hasOldDb() -> Bool {
        let file = ((try! files.getAndEnsureDirectory()) as NSString).stringByAppendingPathComponent("browser.db")
        let status = sqlite3_open_v2(file.cStringUsingEncoding(NSUTF8StringEncoding)!, &db, SQLITE_OPEN_READONLY, nil)
        if status != SQLITE_OK {
            debugPrint("Error: Opening Database with Flags")
            return false
        }
        return true
    }
    
    private func migrateBookmarks(completed: (success: Bool) -> Void) {
        
        completed(success: true)
    }
    
    private func migrateHistory(completed: (success: Bool) -> Void) {
        completed(success: true)
    }
    
    private func migrateDomainData(completed: (success: Bool) -> Void) {
        completed(success: true)
    }
    
    private func migrateFavicons(completed: (success: Bool) -> Void) {
        completed(success: true)
    }
    
    private func migrateTabs(completed: (success: Bool) -> Void) {
        completed(success: true)
    }
    
    private func removeOldDb(completed: (success: Bool) -> Void) {
//        do {
//            try NSFileManager.defaultManager().removeItemAtPath(self.files.rootPath as String)
//            completed(success: true)
//        } catch {
//            debugPrint("Cannot clear profile data: \(error)")
//            completed(success: false)
//        }
        completed(success: false)
    }
    
    private func checkCompleted() {
        var completedAllCalls = true
        for (_, value) in completedCalls {
            if value == false {
                completedAllCalls = false
                break
            }
        }
        
        // All migrations completed, delete the db.
        if completedAllCalls {
            removeOldDb { (success) in
                debugPrint("Delete old database... \(success ? "Done" : "Failed")")
                if let callback = self.completedCallback {
                    callback(success: success)
                }
            }
        }
    }
}
