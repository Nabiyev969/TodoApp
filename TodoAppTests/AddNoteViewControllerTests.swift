//
//  AddNoteViewControllerTests.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 07.09.25.
//

import XCTest
@testable import TodoApp

final class AddNoteViewControllerTests: XCTestCase {
    
    var sut: AddNoteViewController!

    override func setUp() {
        super.setUp()
        sut = AddNoteViewController()
        sut.loadViewIfNeeded()
    }

    func testUIElementsExist() {
        let stackViews = sut.view.subviews.compactMap { $0 as? UIStackView }
        XCTAssertFalse(stackViews.isEmpty)
    }

    func testFillingFieldsWithExistingNote() {
        let note = Notes(context: CoreDataManager().context)
        note.title = "Test Title"
        note.details = "Test Details"
        note.createdAt = Date()

        sut.existingNote = note
        sut.viewDidLoad()
    }
}
