//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

typealias Todo = String

class Presenter {
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"]
    
    weak var view: ViewController?
    
    var todoCount: Int {
        todos.count
    }
    
    func getTodo(index: Int) -> Todo {
        todos[index]
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    func saveTodos(completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(self?.todos.joined(separator: ","), forKey: "todos")
                completion()
            }
        })
    }
    
    func fetchTodos(completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                let data = UserDefaults.standard.string(forKey: "todos")
                self?.todos = data?.components(separatedBy: ",") ?? ["데이터 없음"]
                completion()
            }
        })
    }
    
    func deleteTodos(index: Int) {
        todos.remove(at: index)
    }
}

// Service 분리
class Service {
    private let userDefaluts = UserDefaults.standard
    
    func save(key: String, value: String, completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            self?.userDefaluts.set(value, forKey: key)
            completion()
        })
    }
    
    func fetch(key: String, completion: @escaping (String?)->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            let data = self?.userDefaluts.string(forKey: key)
            completion(data)
        })
    }
}

// 모델 분리
class TodoModel {
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"] {
        didSet {
            todoListener?()
        }
    }
    
    var todoListener: (() -> ())?
    
    let service = Service()
    
    var todoCount: Int {
        todos.count
    }
    
    func getTodo(index: Int) -> Todo {
        todos[index]
    }
    
    func getTodos() -> [Todo] {
        todos
    }
    
    func updateTodos(_ todos: [Todo]) {
        self.todos = todos
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    func saveTodos(completion: @escaping ()->()) {
        let value = todos.joined(separator: ",")
        service.save(key: "todos", value: value) {
            completion()
        }
    }
    
    func fetchTodos(completion: @escaping ()->()) {
        service.fetch(key: "todos") { [weak self] data in
            let todos = data?.components(separatedBy: ",")
            self?.todos = todos ?? [""]
            completion()
        }
    }
    
    func deleteTodos(index: Int) {
        todos.remove(at: index)
    }
    
}

class ViewModel {
    lazy var todoModel: TodoModel = {
        let model = TodoModel()
        model.todoListener = todoListener
        return model
    }()
    
    private var isLoading = false {
        didSet {
            loadingListener?(isLoading)
        }
    }
    
    var todoListener: (() -> ())?
    var loadingListener: ((Bool) -> ())?
    
    var todoCount: Int {
        todoModel.todoCount
    }
    
    func getTodo(index: Int) -> Todo {
        todoModel.getTodo(index: index)
    }
    
    func addTodo(_ todo: Todo) {
        todoModel.addTodo(todo)
    }
    
    func saveTodos() {
        isLoading = true
        todoModel.saveTodos() { [weak self] in
            self?.isLoading = false
        }
    }
    
    func fetchTodos() {
        isLoading = true
        todoModel.fetchTodos() { [weak self] in
            self?.isLoading = false
        }
    }
    
    func deleteTodos(index: Int) {
        todoModel.deleteTodos(index: index)
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
        
        viewModel.todoListener = updateTableview
        viewModel.loadingListener = updateLoadingView
    }
    
    private func updateTableview() {
        DispatchQueue.main.async { [weak self] in
            self?.tableview.reloadData()
        }
    }
    
    private func updateLoadingView(_ flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            flag == true ? self?.indicator.startAnimating() : self?.indicator.stopAnimating()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        alert(title: "할일 추가", message: "", options: "취소", "추가") { [weak self] (alert, index) in
            if index == 1,
               let textField = alert.textFields?.first,
               let text = textField.text,
               text.isEmpty == false {
                self?.viewModel.addTodo(text)
            }
        }
    }
    
    @IBAction func fetchButtonTapped(_ sender: Any) {
        viewModel.fetchTodos()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.saveTodos()
    }
}

extension ViewController {
    func alert(title: String,
               message: String,
               options: String...,
               completion: @escaping (UIAlertController ,Int) -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "할 일을 입력해주세요."
        }
        options.enumerated().forEach { (index, option) in
            alertController.addAction(UIAlertAction(title: option, style: .default, handler: { (action) in
                completion(alertController, index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.todoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = viewModel.getTodo(index: indexPath.row)
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
            viewModel.deleteTodos(index: indexPath.row)
        }
    }
}

