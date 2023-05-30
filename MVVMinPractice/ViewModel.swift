//
//  ViewModel.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/05/27.
//

import Foundation

class ViewModel {
    
    private var todos = ["집안 일", "공부하기", "TIL 쓰기"] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableviewListener?()
            }
        }
    }
    private var isLoading = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loadingListener?(self.isLoading)
            }
        }
    }
    
    private let service = APIService()
    
    var loadingListener: ((Bool) -> ())?
    var tableviewListener: (()->())?
    
    var todosCount: Int { todos.count }
    
    func getTodo(index: Int) -> Todo {
        return todos[index]
    }
    
    func addTodo() {
        todos.append("할일")
    }
    
    func deleteTodo(index: Int) {
        todos.remove(at: index)
    }
    
    func fetchTodos() {
        isLoading = true
        service.fetch(key: "todos") { [weak self] todos in
            self?.todos = todos
            self?.isLoading = false
        }
    }
    
    func saveTodos() {
        isLoading = true
        service.save(key: "todos", value: todos) { [weak self] in
            self?.isLoading = false
        }
    }
    
}
