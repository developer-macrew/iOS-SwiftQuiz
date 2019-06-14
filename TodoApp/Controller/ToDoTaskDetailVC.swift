//
//  DetailVC.swift
//  ListTodo
//
//  Created by Macrew on 11/06/19.
//  Copyright © 2019 Macrew. All rights reserved.
//

import UIKit
import CoreData

class ToDoTaskDetailVC: UIViewController {

    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var detailItem: UINavigationItem!
    
    var titleText: String?
    var detailText: String?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        detailItem.prompt = titleText
        detailTextView.text = detailText
    }
}
