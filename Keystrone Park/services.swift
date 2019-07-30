//
//  services.swift
//  Keystrone Park
//
//  Created by Faizan Khan on 25/07/19.
//  Copyright © 2019 Faizan Khan. All rights reserved.
//

import Foundation
import CoreData

class Services {
    typealias CompletionHandler = (String) -> Void
    enum lessonType: String {
        case ski, snowboard
    }
    
    let managedObjectContext: NSManagedObjectContext
    init(moc: NSManagedObjectContext) {
        self.managedObjectContext = moc
    }
    
    func uploadDataToCoreData(studentName: String, lessonName: String) {
        if lessonName.lowercased() == lessonType.ski.rawValue {
            if checkForExistence(lessonName: lessonName) {
                addStudentToCoreData(studentName: studentName, lessonType: lessonName)
            } else {
                createLessonTypeInCoreData(lessonType: lessonName)
                addStudentToCoreData(studentName: studentName, lessonType: lessonName)
            }
        } else if lessonName.lowercased() == lessonType.snowboard.rawValue {
            if checkForExistence(lessonName: lessonName) {
                addStudentToCoreData(studentName: studentName, lessonType: lessonName)
            } else {
                createLessonTypeInCoreData(lessonType: lessonName)
                addStudentToCoreData(studentName: studentName, lessonType: lessonName)
            }
        } else {
            print("Something went wrong!")
        }
    }
    
    func deleteData(student: Student, CompletionHandler: CompletionHandler) {
        self.deleteStudentEverywhere(student: student)
        do {
            try managedObjectContext.save()
            return CompletionHandler("DeletedAndSaved")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return
    }
    
    private func checkForExistence(lessonName: String) -> Bool {
        let request: NSFetchRequest = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type = %@", lessonName)
        do
        {
            let result = try managedObjectContext.fetch(request)
            if result.count != 0 {
                return true
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return false
    }
    
    private func addStudentToCoreData(studentName: String, lessonType: String) {
        let student = Student(context: managedObjectContext)
        student.name = studentName
        let lesson = Lesson(context: managedObjectContext)
        lesson.type = lessonType
        student.lesson = lesson
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func createLessonTypeInCoreData(lessonType: String) {
        let lesson = Lesson(context: managedObjectContext)
        lesson.type = lessonType
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func fetchData() -> [Student] {
        let request: NSFetchRequest = Student.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            let result = try managedObjectContext.fetch(request)
            return result
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
    func fetchLessonData() -> [Lesson] {
        let request: NSFetchRequest = Lesson.fetchRequest()
        do {
            let result = try managedObjectContext.fetch(request)
            return result
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
    func updateStudentData(oldname: String, studentName: String, lessonType: String, CompletionHandler: CompletionHandler) {
        let request: NSFetchRequest = Student.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", oldname)
        do {
            let result = try managedObjectContext.fetch(request)
            if result.count != 0 {
                self.deleteStudentEverywhere(student: result.first!)
                self.addStudentToCoreData(studentName: studentName, lessonType: lessonType)
                return CompletionHandler("UpdatedSuccessfully")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteStudentEverywhere(student: Student) {
        managedObjectContext.delete(student)
        let lesson = Lesson(context: managedObjectContext)
        lesson.removeFromStudents(student)
    }
}
