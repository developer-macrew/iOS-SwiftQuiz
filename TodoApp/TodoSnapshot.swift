

import Foundation
import Firebase

struct ToDoSnapshot {

	let todoList: [TodoList]

	init?(with snapshot: DataSnapshot) {
		var todos = [TodoList]()
		guard let snapDict = snapshot.value as? [String:[String:AnyObject]] else { return nil }
	
		for snap in snapDict {
			let todo = TodoList(todoId: snap.key, dict: snap.value)!
			todos.append(todo)
		}
		self.todoList = todos
	}
}


