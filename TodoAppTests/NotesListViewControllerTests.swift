//
//  NotesListViewControllerTests.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 07.09.25.
//

import XCTest
@testable import TodoApp

final class NotesListViewControllerTests: XCTestCase {
    
    var sut: NotesListViewController!

    override func setUp() {
        super.setUp()
        sut = NotesListViewController()
        sut.loadViewIfNeeded()
    }

    func testViewControllerHasTableView() {
        XCTAssertNotNil(sut.view.subviews.contains(where: { $0 is UITableView }))
    }
}
