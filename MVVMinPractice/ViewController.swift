//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView?
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    lazy var mainView: View = {
        let view = View()
        view.setDelegate(self)
        return view
    }()
    
    var todos = ["집안 일", "공부하기", "TIL 쓰기"]
    
    override func loadView() {        
        self.view = mainView
//        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: ViewDelegate {
    func todoCount() -> Int {
        return todos.count
    }
    
    func addTodo() {
        todos.append("할일")
    }
    
    func fetchTodos(completion: @escaping () -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            let data = UserDefaults.standard.string(forKey: "todos")
            self?.todos = data?.components(separatedBy: ",") ?? ["데이터 없음"]
            completion()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = todos[indexPath.row]
        return cell ?? UITableViewCell()
    }
}

//extension ViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        todos.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//        cell?.textLabel?.text = todos[indexPath.row]
//        return cell ?? UITableViewCell()
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.imageView?.image = cell?.imageView?.image == nil ? UIImage(systemName: "checkmark") : nil
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        true
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            todos.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//
//}

