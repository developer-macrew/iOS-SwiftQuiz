
import UIKit
import CoreData
import Firebase

class ToDoListVC: ToDoManagedObjectContextBaseClass {
    
    @IBOutlet var tableView: UITableView!
    
    var todoTitleTextField = UITextField()
    var todoDetailsTextField = UITextField()
	var todoFireBaseList = [TodoList]()
	var localArray = [ToDo]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Add observer to get listing from firebase
		DatabaseService.shared.tasksReference.observe(DataEventType.value, with: { (snapshot) in
			if !snapshot.exists(){
				self.todoFireBaseList.removeAll()
				self.tableView.reloadData()
			}
			guard let tasksSnapshot = ToDoSnapshot(with: snapshot) else { return }
			self.todoFireBaseList = tasksSnapshot.todoList
			self.todoFireBaseList.sort(by: { $0.date.compare($1.date) == .orderedDescending })
			self.tableView.reloadData()
		})
		
        setUpTableView()
        GlobalConstants.appDetails.applicationDelegate.context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        // load todo list from local data
        if loadData(){
			todoList = todoList.filter({$0.isDelete == false })
            tableView.reloadData()
        }
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
    }
	

	//MARK: When add button on top is pressed
    @IBAction func addTodoPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Todo Task", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
			let randomString = self.generateRandomDigits(4)
            // Context can't be nil & also Make todoTaskTextField mandatory
            if self.todoTitleTextField.text != ""{
                if let context = GlobalConstants.appDetails.applicationDelegate.context{
                    let todo = ToDo(context: context)
                    let title = self.todoTitleTextField.text
                    let details = self.todoDetailsTextField.text
                    // Nil todos can't be added
                    if let title = title{
                        todo.title = title
                        todo.detail = details
						todo.isSync = false
						todo.isEdited = false
						todo.isDelete = false
						todo.taskId = randomString
                        self.todoList.append(todo)
                        do{
                            try context.save()
							//when data is saved into coreData,we also save that record in firebase
							let dateString = String(describing: Date())
							let parameters = ["title"    : todo.title,
											  "detail"   : todo.detail,
											  "taskId"	 : randomString,
											  "date"     : dateString]
							
							DatabaseService.shared.tasksReference.childByAutoId().setValue(parameters)
                            self.tableView.reloadData()
                        }catch{
                            fatalError("Error storing data")
                        }
                    }
                }
            }else{
                SwiftAlert().show(title: GlobalConstants.appDetails.appName, message: GlobalConstants.AlertMessages.enterToDoTask, viewController: self)
                return
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add Todo Task"
            self.todoTitleTextField = textField
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add Todo Details"
            self.todoDetailsTextField = textField
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func editAction(sender: UIButton){
	  let alert = UIAlertController(title: "Add Todo Task", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Edit Task", style: .default) { (action) in
		
			let status = Reach().connectionStatus()
			switch status {
			case .unknown, .offline:
				let todoItem = self.todoList[sender.tag]
				let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: GlobalConstants.appDetails.applicationDelegate.context!)
				let request = NSFetchRequest<NSFetchRequestResult>()
				request.entity = entity
				
				do {
					var results = try GlobalConstants.appDetails.applicationDelegate.context?.fetch(request)
					let objectUpdate = results?[sender.tag] as! NSManagedObject
					objectUpdate.setValue(self.todoTitleTextField.text, forKey: "title")
					objectUpdate.setValue(self.todoDetailsTextField.text, forKey: "detail")
					objectUpdate.setValue(todoItem.taskId, forKey: "taskId")
					objectUpdate.setValue(true, forKey: "isEdited")
					do {
						for (key,_) in self.todoList.enumerated(){
								if key == sender.tag{
									self.todoList[key].isEdited = true
									self.todoList[key].title = self.todoTitleTextField.text
									self.todoList[key].detail = self.todoDetailsTextField.text
									self.todoList[key].taskId = todoItem.taskId
									self.todoList[key].isEdited = true
								}
							}

						try GlobalConstants.appDetails.applicationDelegate.context?.save()
						self.tableView.reloadData()
					}catch _ as NSError {
						print("error during updation todo list item")
					}
				}catch{
					print("error")
				}
				
			case .online(.wiFi), .online(.wwan):
				let todoFirebaseItem = self.todoFireBaseList[sender.tag]
				let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: GlobalConstants.appDetails.applicationDelegate.context!)
				let request = NSFetchRequest<NSFetchRequestResult>()
				request.entity = entity
				do {
					var results = try GlobalConstants.appDetails.applicationDelegate.context?.fetch(request)
					let objectUpdate = results?[sender.tag] as! NSManagedObject
					objectUpdate.setValue(self.todoTitleTextField.text, forKey: "title")
					objectUpdate.setValue(self.todoDetailsTextField.text, forKey: "detail")
					objectUpdate.setValue(todoFirebaseItem.taskId, forKey: "taskId")
					objectUpdate.setValue(true, forKey: "isEdited")
					do {
						try GlobalConstants.appDetails.applicationDelegate.context?.save()
						self.tableView.reloadData()
						//Also update data in firebase store with that particular id
						let dateString = String(describing: Date())
						let parameters = ["title"    : self.todoTitleTextField.text ?? "",
										  "detail"   : self.todoDetailsTextField.text ?? "",
										  "taskId"	 : todoFirebaseItem.taskId,
										  "date"     : dateString] as [String : AnyObject]
						
						DatabaseService.shared.tasksReference.child(todoFirebaseItem.todoId).setValue(parameters)
					}
					catch _ as NSError {
						print("error during updation todo list item")
					}
				}
				catch{
					print("error")
				}
			}
		}
		
        alert.addTextField { (textField) in
            textField.placeholder = "Add Todo Task"
            self.todoTitleTextField = textField
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Add Todo Details"
            self.todoDetailsTextField = textField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        //Set data to alert controller textfields after its present
		let status = Reach().connectionStatus()
		switch status {
		case .unknown, .offline:
			let todoItem = self.todoList[sender.tag]
			self.todoTitleTextField.text = todoItem.title
			self.todoDetailsTextField.text = todoItem.detail
		case .online(.wwan), .online(.wiFi):
			let todoItem = self.todoFireBaseList[sender.tag]
			self.todoTitleTextField.text = todoItem.todoTitle
			self.todoDetailsTextField.text = todoItem.todoDetail
		}
    }
    
    override func loadData()->Bool{
        if super.loadData(){
            return true
        }
        return false
    }
    
    // MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "detailSegueId"{
			let detailVC = segue.destination as? ToDoTaskDetailVC
			let row = sender as? Int
			if let detailVC = detailVC, let row = row{
				let status = Reach().connectionStatus()
				switch status {
				case .unknown, .offline:
					detailVC.titleText = todoList[row].title
					detailVC.detailText = todoList[row].detail
				case .online(.wwan), .online(.wiFi):
					detailVC.titleText =  todoFireBaseList[row].todoTitle
					detailVC.detailText = todoFireBaseList[row].todoDetail
				}
			}
		}
	}
	
	func generateRandomDigits(_ digitNumber: Int) -> String {
		var number = ""
		for i in 0..<digitNumber {
			var randomNumber = arc4random_uniform(10)
			while randomNumber == 0 && i == 0 {
				randomNumber = arc4random_uniform(10)
			}
			number += "\(randomNumber)"
		}
		return number
	}
}
// MARK: - Extension for tableview methods
extension ToDoListVC: UITableViewDelegate, UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let status = Reach().connectionStatus()
		switch status {
		case .unknown, .offline:
			return todoList.count
		case .online(.wwan), .online(.wiFi):
			return todoFireBaseList.count
		}
	}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		let status = Reach().connectionStatus()
		switch status {
		case .unknown, .offline:
			let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
			
			if !todoList[indexPath.item].isDelete{
			cell.lbl_todoTitle.text = todoList[indexPath.row].title
			cell.btn_edit.tag = indexPath.row
			cell.btn_edit.addTarget(self, action: #selector(editAction), for: .touchUpInside)
				
			return cell
			}
			else {
				return cell
			}
			
		case .online(.wwan), .online(.wiFi):
			 let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
			cell.lbl_todoTitle.text = todoFireBaseList[indexPath.item].todoTitle
			cell.btn_edit.tag = indexPath.row
			cell.btn_edit.addTarget(self, action: #selector(editAction), for: .touchUpInside)
			return cell
			
		}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegueId", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		let status = Reach().connectionStatus()
		switch status {
		case .unknown, .offline:
			if editingStyle == .delete {
				localArray = todoList
				todoList.removeAll()
				self.tableView.reloadData()
				let taskItem = localArray[indexPath.row]
				
				let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: GlobalConstants.appDetails.applicationDelegate.context!)
				let request = NSFetchRequest<NSFetchRequestResult>()
				request.entity = entity
				do{
					var results = try GlobalConstants.appDetails.applicationDelegate.context?.fetch(request)
					let objectUpdate = results?[indexPath.row] as! NSManagedObject
					objectUpdate.setValue(true, forKey: "isDelete")

					do {
						if let context = GlobalConstants.appDetails.applicationDelegate.context{
						let todo = ToDo(context: context)
						todo.title = taskItem.title
						todo.detail = taskItem.detail
						todo.isSync = taskItem.isSync
						todo.isEdited = taskItem.isEdited
						todo.isDelete = true
						todo.taskId = taskItem.taskId

							for (key,_) in localArray.enumerated(){
								if key == indexPath.row{
									localArray[key].isDelete = true
								}
							}
							todoList = localArray
							todoList = todoList.filter({$0.isDelete == false})
							self.tableView.reloadData()
							try context.save()
						}
					}
					catch{
						fatalError("Error storing data")
					}
				}catch{
					print("error")
				}
			}

		case .online(.wiFi), .online(.wwan):
			if editingStyle == .delete {
				let coreDataItem = todoList[indexPath.row]
				let taskItem = todoFireBaseList[indexPath.row]
				//remove from core data
				GlobalConstants.appDetails.applicationDelegate.context?.delete(coreDataItem)
				do{
					try GlobalConstants.appDetails.applicationDelegate.context?.save()
					//Also remove from firebase
					DatabaseService.shared.tasksReference.child(taskItem.todoId).removeValue()
					if todoFireBaseList.count == 1{
						todoFireBaseList.removeAll()
					}
					tableView.reloadData()
				}catch{
					fatalError("Error storing data")
				}
			}
		}
	}
}
