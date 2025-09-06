//
//  AddNoteViewController.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 04.09.25.
//

import UIKit

final class AddNoteViewController: UIViewController {
    
    var existingNote: Notes?
    var updateList: (() -> ())? = nil
    
    private let coreDataManger: CoreDataManager = CoreDataManager()
    
    private let vStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let titleField: UITextField = {
       let field = UITextField()
        field.textColor = .titleColorWhite
        field.font = .systemFont(ofSize: 34, weight: .bold)
        field.placeholder = "Заголовок"
        field.borderStyle = .none
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .isNotDoneButtonColorStroke
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionField: UITextField = {
        let field = UITextField()
        field.textColor = .titleColorWhite
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.placeholder = "Описание"
        field.borderStyle = .none
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundBlack
        
        setupUI()
        configureConstraints()
        
        navigationController?.navigationBar.tintColor = .buttonsColorYellow
        
        if let note = existingNote {
            titleField.text = note.title
            descriptionField.text = note.details
            dateLabel.text = note.createdAt?.formatted()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if let existingNote {
                existingNote.title = titleField.text
                existingNote.details = descriptionField.text
                existingNote.createdAt = Date()
            } else {
                coreDataManger.addNote(title: titleField.text ?? "",
                                       createdDate: Date(),
                                       subtitle: descriptionField.text ?? "")
            }
        }
        updateList?()
    }
    
    private func setupUI() {
        view.addSubview(vStackView)
        
        [titleField, dateLabel, descriptionField].forEach(vStackView.addArrangedSubview)
    }
    
    private func configureConstraints() {
        vStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
