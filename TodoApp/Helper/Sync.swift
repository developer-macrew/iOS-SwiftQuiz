
import UIKit
import CoreData
import  Firebase

class Sync: NSObject {
	static let instance = Sync()
	private var syncDeletedTaskTimer: Timer? = nil
	private var syncEditedTaskTimer: Timer? = nil
	private var syncOfflineTodosTimer: Timer? = nil
	var myGroup = DispatchGroup()
	var inprogress = false
	
	let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
	
	func syncToDoTasks() {
		syncDeletedTaskTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(Sync.syncDeletedToDos), userInfo: nil, repeats: true)
		syncEditedTaskTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(Sync.syncEditedToDos), userInfo: nil, repeats: true)
		syncOfflineTodosTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(Sync.syncOfflineToDos), userInfo: nil, repeats: true)
	}
	
	
	@objc func syncDeletedToDos() {
		if inprogress { return }
		inprogress = true
		let fetchRequest = NSFetchRequest<ToDo>(entityName: "ToDo")
		do {
			let offLineToDoTask = try managedObjectContext?.fetch(fetchRequest)
			if let offlineTaskEntity = offLineToDoTask?.filter({$0.isDelete == true}).first {
				
				DatabaseService.shared.tasksReference.queryOrdered(byChild:"taskId").queryEqual(toValue: offlineTaskEntity.taskId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
					if let snapDict = snapshot.value as? [String:[String:AnyObject]] {
						let key = snapDict.first?.key
						DatabaseService.shared.tasksReference.child(key!).removeValue()
					}
				})
				managedObjectContext?.delete(offlineTaskEntity)
				try managedObjectContext?.save()
			}
		} catch let error {
			inprogress = false
			print("Getting Local Error ==> ", error)
		}
	}
	
	@objc func syncEditedToDos() {
		if inprogress { return }
		inprogress = true
		let fetchRequest = NSFetchRequest<ToDo>(entityName: "ToDo")
		do {
			let offLineToDoTask = try managedObjectContext?.fetch(fetchRequest)
			if let offlineTaskEntity = offLineToDoTask?.filter({$0.isEdited == true}).first {
				
				let dateString = String(describing: Date())
				DatabaseService.shared.tasksReference.queryOrdered(byChild:"taskId").queryEqual(toValue: offlineTaskEntity.taskId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
					if let snapDict = snapshot.value as? [String:[String:AnyObject]] {
						let key = snapDict.first?.key
						let parameters = ["title"    : offlineTaskEntity.title,
										  "detail"   : offlineTaskEntity.detail,
										  "taskId"	 : offlineTaskEntity.taskId,
										  "date"     : dateString]
						DatabaseService.shared.tasksReference.child(key!).setValue(parameters)
					}
				})
			}
		} catch let error {
			inprogress = false
			print("Getting Local Error ==> ", error)
		}
	}
	
	@objc func syncOfflineToDos() {
		if inprogress { return }
		inprogress = true
		let fetchRequest = NSFetchRequest<ToDo>(entityName: "ToDo")
		do {
			let offLineToDoTask = try managedObjectContext?.fetch(fetchRequest)
			if let offlineTripEntity = offLineToDoTask?.filter({$0.isSync == false}).first {
				offlineTripEntity.isSync = true
				try managedObjectContext?.save()
				let dateString = String(describing: Date())
				let parameters = ["title"    : offlineTripEntity.title,
								  "detail"   : offlineTripEntity.detail,
								  "taskId"	 : offlineTripEntity.taskId,
								  "date"     : dateString]
				DatabaseService.shared.tasksReference.childByAutoId().setValue(parameters)
			}
		} catch let error {
			inprogress = false
			print("Getting Local Error ==> ", error)
		}
	}

	func stopSyncing() {
		syncEditedTaskTimer?.invalidate()
		syncDeletedTaskTimer?.invalidate()
		syncOfflineTodosTimer?.invalidate()
	}
}
