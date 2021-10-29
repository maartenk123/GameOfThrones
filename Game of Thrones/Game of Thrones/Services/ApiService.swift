//
//  ApiService.swift
//  Game of Thrones
//
//  Created by Maarten Koe on 22/10/2021.
//

import Foundation

var apiService = APIService()

class APIService {
    
    let endPoint = "https://private-anon-0ea469d4d8-androidtestmobgen.apiary-mock.com/"
    
    func getDataWith(query: String, completion: @escaping (Result<[Any]>) -> Void) {
        let urlString = endPoint + query
        
        print("going to getDataWith \(urlString)")
        
        guard let url = URL(string: urlString) else { return completion(.Error("Invalid URL")) }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "No data returned")) }
            
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [Any] {
                    DispatchQueue.main.async {
                        completion(.Success(array))
                    }
                } else {
                    return completion(.Error(error?.localizedDescription ?? "Null JSON"))
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
    
    func getCategories(completion: @escaping (Result<[Any]>) -> Void) {
        let query = "categories"
        
        apiService.getDataWith(query: query) { (result) in
            completion(result)
        }
    }
    
    func getList(categoryType: Int64, completion: @escaping (Result<[Any]>) -> Void) {
        let query = "list/\(categoryType+1)"
        
        apiService.getDataWith(query: query) { (result) in
            completion(result)
        }
    }
}

enum Result<T> {
    case Success(T)
    case Error(String)
}
