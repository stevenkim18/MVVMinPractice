//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

typealias Todo = String

// 여기서
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

// binding didset
class ViewModel {
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"] {
        didSet {
            todoListener?()
        }
    }
    
    var todoListener: (() -> ())?
    
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

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
        
//    let presenter = Presenter()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        viewModel.todoListener = updateTableview
    }
    
    private func updateTableview() {
        tableview.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "할 일 추가", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text {
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
        indicator.startAnimating()
        viewModel.fetchTodos() { [weak self] in
            self?.indicator.stopAnimating()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        indicator.startAnimating()
        viewModel.saveTodos() { [weak self] in
            self?.indicator.stopAnimating()
        }
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

