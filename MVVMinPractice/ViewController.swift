//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

// 데이터 모델
typealias Todo = String

class Presenter {
    
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"]
//    weak var view: ViewController?
    
    var todoCount: Int {
        todos.count
    }
    
    func getTodo(index: Int) -> Todo {
        todos[index]
    }
    
    func addTodo(_ todo: Todo) {
        self.todos.append(todo)
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
    
    func saveTodos(completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(self?.todos.joined(separator: ","), forKey: "todos")
                completion()
            }
        })
    }
    
    func removeTodo(index: Int) {
        todos.remove(at: index)
    }
}

class Model {
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"] {
        didSet {
            todosListener?()
        }
    }
    
    var todosListener: (() -> ())?
    
    var todoCount: Int {
        todos.count
    }
    
    func getTodo(index: Int) -> Todo {
        todos[index]
    }
    
    func addTodo(_ todo: Todo) {
        self.todos.append(todo)
    }
    
    func fetchTodos(completion: @escaping () -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                let data = UserDefaults.standard.string(forKey: "todos")
                self?.todos = data?.components(separatedBy: ",") ?? ["데이터 없음"]
                completion()
            }
        })
    }
    
    func saveTodos(completion: @escaping () -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(self?.todos.joined(separator: ","), forKey: "todos")
                completion()
            }
        })
    }
    
    func removeTodo(index: Int) {
        todos.remove(at: index)
    }
}


// binding -> didset
class ViewModel {
    
    lazy var model: Model = {
        let model = Model()
        // TODO: 모델을 직접 바인딩 하지 않고 뷰모델 만을 바인딩 하는 방법.
        model.todosListener = self.todosListener
        return model
    }()
    
    private var isLoading = false {
        didSet {
            loadingListener?(isLoading)
        }
    }
    
    var todosListener: (() -> ())?
    var loadingListener: ((Bool)->())?
    
    var todoCount: Int {
        model.todoCount
    }
    
    func getTodo(index: Int) -> Todo {
        model.getTodo(index: index)
    }
    
    func addTodo(_ todo: Todo) {
        model.addTodo(todo)
    }
    
    func fetchTodos() {
        isLoading = true
        model.fetchTodos() { [weak self] in
            self?.isLoading = false
        }
    }
    
    func saveTodos() {
        isLoading = true
        model.saveTodos() { [weak self] in
            self?.isLoading = false
        }
    }
    
    func removeTodo(index: Int) {
        model.removeTodo(index: index)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let viewmodel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        viewmodel.todosListener = updateTableView
        viewmodel.loadingListener = updateLoadingView
    }
    
    // MARK - bind funcs
    private func updateTableView() {
        tableview.reloadData()
    }
    
    private func updateLoadingView(_ isLoading: Bool) {
        isLoading == true ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text, text.isEmpty == false {
                guard let self = self else { return }
                viewmodel.addTodo(text)
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
        viewmodel.fetchTodos()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewmodel.saveTodos()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewmodel.todoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = viewmodel.getTodo(index: indexPath.row)
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
        viewmodel.removeTodo(index: indexPath.row)
    }
}

