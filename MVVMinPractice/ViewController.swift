//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

class Observable<T> {
    var listener: ((T) -> Void)?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: ((T) -> Void)?) {
        self.listener = listener
    }
}

protocol Service {
    func fetch(completion: @escaping (String)->())
    func save(data: String, completion: @escaping ()->())
}

class UserDefaultsService: Service {
    enum Const {
        static let key = "todos"
    }
    
    func fetch(completion: @escaping (String)->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            let data = UserDefaults.standard.string(forKey: Const.key) ?? ""
            completion(data)
        })
    }
    
    func save(data: String, completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            UserDefaults.standard.set(data, forKey: Const.key)
            completion()
        })
    }
}

class Model {
    var todos: Observable<[String]> = .init(["집안 일", "공부하기", "TIL 쓰기"])
    
    var todosCount: Int {
        todos.value.count
    }
    
    let service = UserDefaultsService()
    
    func addTodo(_ todo: String) {
        todos.value.append(todo)
    }
    
    func fetchTodos(completion: @escaping ()->()) {
        service.fetch { [weak self] data in
            let todos = data.components(separatedBy: ",")
            self?.todos.value = todos
            completion()
        }
    }
    
    func saveTodos(completion: @escaping ()->()) {
        let data = self.todos.value.joined(separator: ",")
        service.save(data: data) {
            completion()
        }
    }
    
    func todo(at index: Int) -> String {
        return todos.value[index]
    }
    
    func removeTodo(at index: Int) {
        todos.value.remove(at: index)
    }
}

class ViewModel {
    var isLoading: Observable<Bool> = .init(false)
    
    let model = Model()
    
    var todosCount: Int {
        return model.todosCount
    }
    
    func bindModel(listener: (([String])->())?) {
        model.todos.bind(listener)
    }
    
    func addTodo(_ todo: String) {
        model.addTodo(todo)
    }
    
    func fetchTodos() {
        self.isLoading.value = true
        model.fetchTodos { [weak self] in
            self?.isLoading.value = false
        }
    }
    
    func saveTodos() {
        self.isLoading.value = true
        model.saveTodos {  [weak self] in
            self?.isLoading.value = false
        }
    }
    
    func todo(at index: Int) -> String {
        return model.todo(at: index)
    }
    
    func removeTodo(at index: Int) {
        model.removeTodo(at: index)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.bindModel(listener: { _ in
            DispatchQueue.main.async { [weak self] in
                self?.tableview.reloadData()
            }
        })
        viewModel.isLoading.bind { isLoading in
            DispatchQueue.main.async { [weak self] in
                isLoading ? self?.indicator.startAnimating() : self?.indicator.stopAnimating()
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text, text.isEmpty == false {
                guard let self = self else { return }
                self.viewModel.addTodo(text)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "할 일을 입력해주세요."
        }
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func fetchButtonTapped(_ sender: Any) {
        self.viewModel.fetchTodos()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.viewModel.saveTodos()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.todosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = self.viewModel.todo(at: indexPath.row)
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
            self.viewModel.removeTodo(at: indexPath.row)
        }
    }
}

