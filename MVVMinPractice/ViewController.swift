//
//  ViewController.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/04/29.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var todos = ["집안 일", "공부하기", "TIL 쓰기"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        todos.append("할일")
        tableview.performBatchUpdates {
            tableview.insertRows(at: [IndexPath(row: todos.count-1, section: 0)], with: .automatic)
        }
    }
    
    @IBAction func fetchData(_ sender: Any) {
        indicator.startAnimating()
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
            DispatchQueue.main.async { [weak self] in
                self?.indicator.stopAnimating()
                self?.todos = ["야곰 강의 보기", "청소 하기", "코테 준비"]
                self?.tableview.reloadData()
            }
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = todos[indexPath.row]
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
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

