//
//  Presenter.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/05/27.
//

import UIKit

class Presenter {
    
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"]
    
    weak var view: UIViewController?
    
    let service = APIService()
    
    func todo(index: Int) -> Todo {
        todos[index]
    }
    
    func todoCount() -> Int {
        todos.count
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
    }
    
    func removeTodo(index: Int) {
        todos.remove(at: index)
    }
    
    func fetchTodos(completion: @escaping ()->()) {
        service.fetch(key: "todos") { [weak self] todos in
            guard let self = self else { return }
            self.todos = todos
            completion()
        }
    }
    
    func saveTodos(completion: @escaping ()->()) {
        service.save(key: "todos", value: todos) {
            completion()
        }
    }
}
