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
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            guard let self = self else { return }
            let data = UserDefaults.standard.string(forKey: "todos")
            self.todos = data?.components(separatedBy: ",") ?? ["데이터 없음"]
            completion()
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
}
