
import Foundation
import UIKit


struct GlobalConstants {
    struct appDetails {
        static let appName = "ToDo List"
        static let website = ""
        static let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
		static let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
    }
	
	struct AlertMessages{
		static let enterToDoTask  = "Empty todo task can't be added!"
	}
}
