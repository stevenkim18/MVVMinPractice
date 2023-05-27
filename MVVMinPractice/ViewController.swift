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
        view.delegate = self
//        view.setDelegate(self)
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
    func getTodo(index: Int) -> String {
        todos[index]
    }
    
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
    
    func removeTodo(index: Int) {
        todos.remove(at: index)
    }
}
