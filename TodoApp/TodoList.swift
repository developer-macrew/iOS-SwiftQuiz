

import Foundation


struct TodoList {
	let todoId: String
	let todoTitle: String
	let todoDetail: String
	let taskId: String
	let date: Date
	
	init?(todoId: String, dict: [String: AnyObject]) {
		self.todoId = todoId
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
		
		guard let todoTitle = dict["title"] as? String,
			let todoDetail = dict["detail"] as? String,
			let taskId = dict["taskId"] as? String,
			let dateString = dict["date"] as? String,
			let date = dateFormatter.date(from: dateString)
			else { return nil }
		
		self.todoTitle = todoTitle
		self.todoDetail = todoDetail
		self.taskId = taskId
		self.date = date
	}
}
