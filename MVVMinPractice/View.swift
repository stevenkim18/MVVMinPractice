//
//  View.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/05/26.
//

import UIKit

protocol ViewDelegate: AnyObject {
    func getTodo(index: Int) -> String
    func todoCount() -> Int
    func addTodo()
    func fetchTodos(completion: @escaping () -> ())
    func saveTodos(completion: @escaping () -> ())
    func removeTodo(index: Int)
}

class View: UIView {
    
    private let tableview: UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.backgroundColor = .cyan
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableview
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private lazy var addBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonTapped))
        return barButton
    }()
    
    private lazy var fetchBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "불러오기", style: .plain, target: self, action: #selector(fetchButtonTapped))
        return barButton
    }()
    
    private lazy var saveBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "저장하기", style: .plain, target: self, action: #selector(saveButtonTapped))
        return barButton
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.style = .large
        indicatorView.backgroundColor = .gray.withAlphaComponent(0.5)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    weak var delegate: ViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func setDelegate(_ delegate: ViewDelegate) {
//        self.delegate = delegate
//        tableview.delegate = delegate
//        tableview.dataSource = delegate
//    }
    
    // MARK: Private
    private func configureUI() {
        self.backgroundColor = .systemBackground
        self.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        self.addSubview(toolbar)
        toolbar.items = [addBarButton, fetchBarButton, saveBarButton]
        self.addSubview(indicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            tableview.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: self.self.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.self.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            indicatorView.topAnchor.constraint(equalTo: self.topAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    // MARK: Button Action
    @objc func addButtonTapped() {
        let count = delegate?.todoCount()
        delegate?.addTodo()
        tableview.performBatchUpdates {
            tableview.insertRows(at: [IndexPath(row: (count ?? 0), section: 0)], with: .automatic)
        }
    }
    
    @objc func fetchButtonTapped() {
        indicatorView.startAnimating()
        delegate?.fetchTodos() {
            DispatchQueue.main.async { [weak self] in
                self?.tableview.reloadData()
                self?.indicatorView.stopAnimating()
            }
        }
    }
    
    @objc func saveButtonTapped() {
        indicatorView.startAnimating()
        delegate?.saveTodos {
            DispatchQueue.main.async { [weak self] in
                self?.indicatorView.stopAnimating()
            }
        }
    }
}

extension View: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.todoCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = delegate?.getTodo(index: indexPath.row)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.imageView?.image = cell?.imageView?.image == nil ? UIImage(systemName: "checkmark") : nil
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.removeTodo(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

