//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

typealias Todo = String

class ViewController: UIViewController {
    
    lazy var mainView: View = {
        let view = View()
        view.delegate = self
        return view
    }()
    
    let presenter = Presenter()
        
    override func loadView() {        
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: ViewDelegate {
    func getTodo(index: Int) -> String {
        presenter.todo(index: index)
    }
    
    func todoCount() -> Int {
        presenter.todoCount()
    }
    
    func addTodo() {
        presenter.addTodo("할일")
    }
    
    func fetchTodos(completion: @escaping () -> ()) {
        presenter.fetchTodos {
            completion()
        }
    }
    
    func saveTodos(completion: @escaping () -> ()) {
        presenter.saveTodos {
            completion()
        }
    }
    
    func removeTodo(index: Int) {
        presenter.removeTodo(index: index)
    }
}
