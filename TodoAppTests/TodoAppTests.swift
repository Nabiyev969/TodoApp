//
//  TodoAppTests.swift
//  TodoAppTests
//
//  Created by Nabiyev Anar on 03.09.25.
//

import XCTest
@testable import TodoApp

final class TodoAppTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager()
        
        let allNotes = coreDataManager.fetchNotes()
        for note in allNotes {
            coreDataManager.delete(item: note)
        }
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
        try super.tearDownWithError()
    }

    func testAddNote() throws {
        let title = "Test Title"
        let details = "Test Details"
        let date = Date()
        
        coreDataManager.addNote(title: title, createdDate: date, subtitle: details)
        let notes = coreDataManager.fetchNotes()
        
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, title)
        XCTAssertEqual(notes.first?.details, details)
    }

    func testIsDoneToggle() throws {
        coreDataManager.addNote(title: "Toggle Me", createdDate: Date(), subtitle: "Toggling")
        var note = coreDataManager.fetchNotes().first!
        
        let originalValue = note.isDone
        coreDataManager.isDone(item: note)
        note = coreDataManager.fetchNotes().first!
        
        XCTAssertNotEqual(note.isDone, originalValue)
    }

    func testDeleteNote() throws {
        coreDataManager.addNote(title: "To Be Deleted", createdDate: Date(), subtitle: "Desc")
        let notesBefore = coreDataManager.fetchNotes()
        XCTAssertEqual(notesBefore.count, 1)
        
        if let note = notesBefore.first {
            coreDataManager.delete(item: note)
        }
        
        let notesAfter = coreDataManager.fetchNotes()
        XCTAssertEqual(notesAfter.count, 0)
    }
}
