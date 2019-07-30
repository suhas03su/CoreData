//
//  ListTableViewController.swift
//  Keystrone Park
//
//  Created by Faizan Khan on 23/07/19.
//  Copyright © 2019 Faizan Khan. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {

    var managedObjectContext = CoreDataStack().persistentContainer.viewContext
    var studentList = [Student]()
    var lessonType = [Lesson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        cell.textLabel?.text = studentList[indexPath.row].name
        cell.detailTextLabel?.text = studentList[indexPath.row].lesson?.type
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let services = Services(moc: self.managedObjectContext)
            services.deleteData(student: studentList[indexPath.row]) { (response) in
                if response == "DeletedAndSaved" {
                    DispatchQueue.main.async {
                        self.fetchData()
                        self.tableView.reloadData()
                    }
                } else {
                    print("Exception was caught")
                }
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Student", message: "If you wish to edit a student, you can!", preferredStyle: .alert)
        alertController.addTextField { (studentName) in
            studentName.text = self.studentList[indexPath.row].name
        }
        alertController.addTextField { (lessonName) in
            lessonName.text = self.studentList[indexPath.row].lesson?.type
        }
        let addAction = UIAlertAction(title: "Update", style: .default) { (action) in
            guard let studentName = alertController.textFields?[0].text, let lessonName = alertController.textFields?[1].text else { return }
            let services = Services(moc: self.managedObjectContext)
            services.updateStudentData(oldname: self.studentList[indexPath.row].name!, studentName: studentName, lessonType: lessonName, CompletionHandler: { (response) in
                if response != "" {
                    DispatchQueue.main.async {
                        self.fetchData()
                        self.tableView.reloadData()
                    }
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addStudentTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Student", message: "Add the student to either Ski or Snowboard", preferredStyle: .alert)
        alertController.addTextField { (studentName) in
            studentName.placeholder = "Name of the student to be enrolled"
        }
        alertController.addTextField { (lessonName) in
            lessonName.placeholder = "Add the above student to Ski or Snowboard"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            //Call Core Data Stack from here
            guard let studentName = alertController.textFields?[0].text, let lessonName = alertController.textFields?[1].text else { return }
            let services = Services(moc: self.managedObjectContext)
            services.uploadDataToCoreData(studentName: studentName, lessonName: lessonName)
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.fetchData()
                self.tableView.reloadData()
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func fetchData(){
        let services = Services(moc: managedObjectContext)
        studentList = services.fetchData()
    }
    

}
