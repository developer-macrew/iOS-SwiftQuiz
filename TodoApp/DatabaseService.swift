
import Foundation
import Firebase

class DatabaseService {
	
	static let shared = DatabaseService()
	private init() {}
	
	let tasksReference = Database.database().reference().child("task")
	
}
