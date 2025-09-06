//
//  NotesTableViewCell.swift
//  TodoApp
//
//  Created by Nabiyev Anar on 03.09.25.
//

import UIKit

final class NotesTableViewCell: UITableViewCell {
    
    var isDoneToggle: (() -> ())?
    
    private let mainStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        return stack
    }()
    
    private lazy var isDoneButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(didTapIsDoneButton), for: .touchUpInside)
        return button
    }()
    
    private let titlesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .titleColorWhite
        return label
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .titleColorWhite
        return label
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .completedTitleColorWhite
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainStackView)
        [isDoneButton, titlesStackView].forEach(mainStackView.addArrangedSubview)
        [titleLabel, descriptionLabel, dateLabel].forEach(titlesStackView.addArrangedSubview)
    }
    
    private func configureConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
        }
        isDoneButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    @objc
    private func didTapIsDoneButton() {
        isDoneToggle?()
    }
}

extension NotesTableViewCell {
    struct Item {
        let title: String
        let details: String
        let date: String
        let isDone: Bool
    }
    
    func configure(item: Item) {
        self.titleLabel.text = item.title
        self.descriptionLabel.text = item.details
        self.dateLabel.text = item.date
        
        if item.isDone {
            self.isDoneButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            self.isDoneButton.tintColor = .buttonsColorYellow
            self.titleLabel.textColor = .completedTitleColorWhite
            self.descriptionLabel.textColor = .completedTitleColorWhite
        } else {
            self.isDoneButton.setImage(UIImage(systemName: "circle"), for: .normal)
            self.isDoneButton.tintColor = .isNotDoneButtonColorStroke
            self.titleLabel.textColor = .titleColorWhite
            self.descriptionLabel.textColor = .titleColorWhite
        }
    }
}
