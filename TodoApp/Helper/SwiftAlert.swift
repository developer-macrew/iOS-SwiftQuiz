

import Foundation
import UIKit

public class SwiftAlert {
    
    var okAction : (()->())?
    
    public func show(title : String, message : String, viewController : UIViewController, okAction : (()->())? = nil) {
        
        let version:NSString = UIDevice.current.systemVersion as NSString;
        
        if  version.doubleValue >= 8 {
            let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                
                if let _okAction = okAction {
                    
                    _okAction()
                }
            }))
            
            viewController.present(alert, animated:true, completion:nil);
            
            }
        }
	
	public func showLogout(title : String, message : String, viewController : UIViewController, okAction : (()->())? = nil) {
		
		let version:NSString = UIDevice.current.systemVersion as NSString;
		
		if  version.doubleValue >= 8 {
			let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle:.alert)
			alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction) in
				
				if let _okAction = okAction {
					
					_okAction()
				}
			}))
			
			viewController.present(alert, animated:true, completion:nil);
			
		}
	}
    public func showWithCancelAndOk(title : String, okTitle : String, cancelTitle : String, message : String, viewController : UIViewController, okAction : (()->())? = nil, cancelAction : (()->())? = nil) {
        let version:NSString = UIDevice.current.systemVersion as NSString;
        
        if  version.doubleValue >= 8 {
            let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle:.alert)
            
            alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { (action: UIAlertAction) in
                
                if let _okAction = cancelAction {
                    
                    _okAction()
                }
            }))
            alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (action: UIAlertAction) in
                
                if let _okAction = okAction {
                    
                    _okAction()
                }
            }))
            viewController.present(alert, animated:true, completion:nil);
        }
    }
    

}
