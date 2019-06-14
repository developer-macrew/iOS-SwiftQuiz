
import UIKit
import CoreData

class ToDoManagedObjectContextBaseClass: UIViewController {

	// Items list to store todos
	public var todoList: [ToDo] = []
	// Core data context
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// Load data from  coredata
	public func loadData()->Bool{
		let request:NSFetchRequest<ToDo> = ToDo.fetchRequest()
		do{
			if let context = GlobalConstants.appDetails.applicationDelegate.context{
				todoList = try context.fetch(request)
				return true
			}
		}catch{
			print("Error fetching data")
		}
		return false
	}

}
