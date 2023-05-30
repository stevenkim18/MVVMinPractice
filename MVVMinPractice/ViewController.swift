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
    let viewModel = ViewModel()
        
    override func loadView() {        
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadingListener = mainView.setIndicatorView
        viewModel.tableviewListener = mainView.reloadTableview
    }
}

extension ViewController: ViewDelegate {
    func getTodo(index: Int) -> String {
        return viewModel.getTodo(index: index)
    }
    
    func todoCount() -> Int {
        viewModel.todosCount
    }
    
    func addTodo() {
        viewModel.addTodo()
    }
    
    func fetchTodos() {
        viewModel.fetchTodos()
    }
    
    func saveTodos() {
        viewModel.saveTodos()
    }
    
    func removeTodo(index: Int) {
        viewModel.deleteTodo(index: index)
    }
}
