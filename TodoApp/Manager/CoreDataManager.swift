//
//  CoreDataManager.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 04.09.25.
//

import UIKit
import CoreData

class CoreDataManager {
    
    let context: NSManagedObjectContext
    let appDelegate: AppDelegate
    
    init() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDelegate.persistentContainer.viewContext
    }
    
    func addNote(title: String, createdDate: Date, subtitle: String) {
        if title != "" && subtitle != "" {
            let item = Notes(context: context)
            item.title = title
            item.createdAt = createdDate
            item.details = subtitle
            appDelegate.saveContext()
        }
    }
    
    func fetchNotes() -> [Notes] {
        do {
            return try context.fetch(Notes.fetchRequest()).reversed()
        } catch {
            print("Something went wrong while fetch notes: \(error)")
            return []
        }
    }
    
    func delete(item: Notes) {
        context.delete(item)
        appDelegate.saveContext()
    }
    
    func isDone(item: Notes) {
        item.isDone = !item.isDone
        appDelegate.saveContext()
    }
    
    func fetchAndStoreRemoteNotesIfNeeded() {
        let hasLoadedNotesKey = "hasLoadedRemoteNotes"
        
        if UserDefaults.standard.bool(forKey: hasLoadedNotesKey) {
            return
        }
        
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil else {
                print("Downloading error: \(error?.localizedDescription ?? "nil")")
                return
            }
            do {
                let decoded = try JSONDecoder().decode(NotesResponse.self, from: data)
                DispatchQueue.main.async {
                    for remoteNote in decoded.todos {
                        let note = Notes(context: self.context)
                        note.title = remoteNote.todo
                        note.details = ""
                        note.isDone = remoteNote.completed
                        note.createdAt = Date()
                    }
                    self.appDelegate.saveContext()
                    UserDefaults.standard.set(true, forKey: hasLoadedNotesKey)
                }
            } catch {
                print("Parsing error: \(error)")
            }
        }.resume()
    }
}
