//
//  Service.swift
//  MVVMinPractice
//
//  Created by seungwooKim on 2023/05/27.
//

import Foundation

protocol Service {
    
}

class APIService: Service {
    
    private let userDefaluts = UserDefaults.standard
    
    func save(key: String, value: [Todo], completion: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            self?.userDefaluts.set(value.joined(separator: ","), forKey: key)
            completion()
        })
    }
    
    func fetch(key: String, completion: @escaping ([Todo])->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            let data = self?.userDefaluts.string(forKey: "todos")
            let todos = data?.components(separatedBy: ",") ?? ["데이터 없음"]
            completion(todos)
        })
    }
}
