//
//  NotesModel.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 07.09.25.
//

import Foundation

struct RemoteNote: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

struct NotesResponse: Codable {
    let todos: [RemoteNote]
}
