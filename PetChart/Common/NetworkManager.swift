//
//  NetworkManager.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit
import Alamofire
typealias ResSuccess = (Any?) -> Void
typealias ResFailure = (Any?) ->Void

enum ContentType: String {
    case json = "application/json"
    case formdata = "multipart/form-data"
    case urlencoded = "application/x-www-form-urlencoded"
}
class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    func getFullUrl(_ url:String) -> String {
        return "\(SERVER_PREFIX)/\(url)"
    }
    
    func post(_ url: String, _ param: Dictionary<String, Any>, success: ResSuccess?, failure: ResFailure?) {
        
        let fulUrl = self.getFullUrl(url)
        let headers: HTTPHeaders = [.accept(ContentType.json.rawValue)]
        let request = AF.request(fulUrl, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
        
        let startTime = CACurrentMediaTime()
        request.responseJSON { (response:AFDataResponse<Any>) in
            let endTime = CACurrentMediaTime()
            print("request url: \(String(describing: response.request?.url?.absoluteString))")
            print("take time: \(endTime - startTime)")
            
            switch response.result {
            case .success(let result):
                let statusCode: Int = response.response!.statusCode as Int
                if (statusCode >= 200) && (statusCode <= 300) {
                    if let success = success {
                        success(result)
                    }
                }
                else {
                    if let failure = failure {
                        failure(result)
                    }
                }
                
                break
            case .failure(let error as NSError?):
                if let failure = failure {
                    failure(error)
                }
                break
            }
        }
    }
    
    func get(_ url: String, success:@escaping ResSuccess, failure:@escaping ResFailure) {
        
    }
        
    func put(_ url: String, _ param: Dictionary<String, Any>, success:@escaping ResSuccess, failure:@escaping ResFailure) {
        
    }
    
    func delete(_ url: String, _ param: Dictionary<String, Any>, success:@escaping ResSuccess, failure:@escaping ResFailure) {
        
    }
}
