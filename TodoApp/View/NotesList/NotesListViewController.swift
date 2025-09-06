//
//  NotesListViewController.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 03.09.25.
//

import UIKit
import SnapKit

final class NotesListViewController: UIViewController {
    
    private let coreDataManager: CoreDataManager = CoreDataManager()
    private var notesList: [Notes] = [] {
        didSet {
            tableView.reloadData()
            updateNotesCountLabel()
            filterNotes()
        }
    }
    private var filteredNotesList: [Notes] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotesTableViewCell.self, forCellReuseIdentifier: NotesTableViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .isNotDoneButtonColorStroke
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    
    private let bottomView: UIView = {
       let view = UIView()
        view.backgroundColor = .brandGray
        return view
    }()
   
    private lazy var addNoteButton: UIButton = {
       let button = UIButton()
        button.setImage(.addNote, for: .normal)
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var notesCountLabel: UILabel = {
       let label = UILabel()
        label.textColor = .titleColorWhite
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.text = "0 Задач"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundBlack
        
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.backgroundColor = .brandGray
        searchController.searchBar.tintColor = .brandGray
        
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.isNotDoneButtonColorStroke] )
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.titleColorWhite]
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        setupUI()
        configureConstraints()
        
        coreDataManager.fetchAndStoreRemoteNotesIfNeeded()
        DispatchQueue.main.async {
            self.notesList = self.coreDataManager.fetchNotes()
        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        bottomView.addSubview(addNoteButton)
        bottomView.addSubview(notesCountLabel)
    }
    
    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        bottomView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(83)
        }
        addNoteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.safeAreaLayoutGuide)
        }
        notesCountLabel.snp.makeConstraints { make in
            make.centerX.equalTo(bottomView)
            make.top.equalToSuperview().offset(20.5)
        }
    }
    
    private func updateNotesCountLabel() {
        notesCountLabel.text = "\(notesList.count) Задач"
    }
    
    private func filterNotes(with text: String = "") {
        if text.isEmpty {
            filteredNotesList = notesList
        } else {
            filteredNotesList = notesList.filter {
                ($0.title?.localizedCaseInsensitiveContains(text) ?? false) ||
                ($0.details?.localizedCaseInsensitiveContains(text) ?? false)
            }
        }
        tableView.reloadData()
    }

    @objc
    private func didTapAddButton() {
        let vc = AddNoteViewController()
        vc.updateList = {
            self.notesList = self.coreDataManager.fetchNotes()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotesListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.identifier, for: indexPath) as? NotesTableViewCell {
            let item = filteredNotesList[indexPath.row]
            cell.configure(
                item: NotesTableViewCell.Item(title: item.title ?? "",
                                              details: item.details ?? "",
                                              date: item.createdAt?.formatted() ?? "",
                                              isDone: item.isDone)
            )
            cell.isDoneToggle = { [weak self] in
                guard let self = self else { return }
                self.coreDataManager.isDone(item: item)
                self.notesList = self.coreDataManager.fetchNotes()
            }
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = filteredNotesList[indexPath.row]
        
        let editor = AddNoteViewController()
        editor.existingNote = note
        editor.updateList = { [weak self] in
            self?.notesList = self?.coreDataManager.fetchNotes() ?? []
        }
        navigationController?.pushViewController(editor, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        _ = notesList[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            guard self != nil else { return nil }
            
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                let note = self?.notesList[indexPath.row]
                
                let editor = AddNoteViewController()
                editor.existingNote = note
                editor.updateList = { [weak self] in
                    self?.notesList = self?.coreDataManager.fetchNotes() ?? []
                }
                self?.navigationController?.pushViewController(editor, animated: true)
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash")) { [weak self] _ in
                self?.coreDataManager.delete(item: self!.notesList[indexPath.row])
                self?.notesList = self?.coreDataManager.fetchNotes() ?? []
            }
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
    
    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = tableView.cellForRow(at: indexPath) else { return nil }
        let params = UIPreviewParameters()
        params.backgroundColor = .brandGray
        return UITargetedPreview(view: cell.contentView, parameters: params)
    }
    
    func tableView(_ tableView: UITableView,
                   previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = tableView.cellForRow(at: indexPath) else { return nil }
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        return UITargetedPreview(view: cell.contentView, parameters: params)
    }
}

extension NotesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        filterNotes(with: text)
        tableView.reloadData()
    }
}
