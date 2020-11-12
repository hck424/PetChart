//
//  NetworkManager.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias ResSuccess = (Any?) -> Void
typealias ResFailure = (Any?) ->Void

enum ContentType: String {
    case json = "application/json"
    case formdata = "multipart/form-data"
    case urlencoded = "application/x-www-form-urlencoded"
    case text = "text/plain"
}
class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    func getFullUrl(_ url:String) -> String {
        return "\(SERVER_PREFIX)\(url)"
    }
    
    func request(_ method: HTTPMethod, _ url: String, _ param:[String :Any]?, success:ResSuccess?, failure:ResFailure?) {
        let fulUrl = self.getFullUrl(url)
        let encodedUrl:String = fulUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var headers: HTTPHeaders?
        if let token = SharedData.getToken() {
            let auth = HTTPHeader(name: "X-AUTH-TOKEN", value: token)
            headers = [.contentType(ContentType.json.rawValue), .accept(ContentType.json.rawValue), auth]
//            print("X-AUTH-TOKEN: \(token)")
        } else {
            headers = [.contentType(ContentType.json.rawValue), .accept(ContentType.json.rawValue)]
        }
        
        let request = AF.request(encodedUrl, method: method, parameters: param, encoding: JSONEncoding.default, headers: headers)
        
        AppDelegate.instance()?.startIndicator()
        let startTime = CACurrentMediaTime()
        
        request.responseJSON { (response:AFDataResponse<Any>) in
            let endTime = CACurrentMediaTime()
            if let url = response.request?.url?.absoluteString {
                print("\n\n =======request ======= \nurl: \(String(describing: url))")
                if let param = param {
                    print(String(describing: param))
                }
            }
            print("take time: \(endTime - startTime)")
            print("======= response ======= \n\(response)")
            
            AppDelegate.instance()?.stopIndicator()
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
                    self.errorDebugPring(result)
                }
                
                break
            case .failure(let error as NSError?):
                if let failure = failure {
                    failure(error)
                    self.errorDebugPring(error)
                }
                break
            }
        }
    }
    
    func requestFormdataType(_ method: HTTPMethod, _ url: String, _ param:[String :Any]?, success:ResSuccess?, failure:ResFailure?) {
        
        guard let param = param else {
            failure?(nil)
            return
        }
        
        let fulUrl = self.getFullUrl(url)
        
        var headers: HTTPHeaders?
        
        if let token = SharedData.getToken() {
            let auth = HTTPHeader(name: "X-AUTH-TOKEN", value: token)
            headers = [.contentType(ContentType.formdata.rawValue), .accept(ContentType.json.rawValue), auth]
//            print("== X-AUTH-TOKEN: \(token)")
        } else {
            headers = [.contentType(ContentType.formdata.rawValue), .accept(ContentType.json.rawValue)]
        }
        AppDelegate.instance()?.startIndicator()
        let startTime = CACurrentMediaTime()
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if key == "images" {
                    if let value = value as? Array<UIImage> {
                        for img in value {
                            let imgData = img.jpegData(compressionQuality: 1.0)
                            
                            if let imgData = imgData {
                                multipartFormData.append(imgData, withName: "files", fileName: "\(Date().timeIntervalSince1970).png", mimeType: "image/png")
                                print(" == imgData byte: \(ByteCountFormatter().string(fromByteCount: Int64(imgData.count)))")
                            }
                        }
                    }
                }
                else {
                    let data:Data? = "\(value)".data(using: .utf8)
                    if let data = data {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
        }, to: fulUrl, method: method, headers: headers).responseJSON { (response) in
            AppDelegate.instance()?.stopIndicator()
            let endTime = CACurrentMediaTime()
            if let url = response.request?.url?.absoluteString {
                print("\n\n =======request ======= \nurl: \(String(describing: url))")
                print(String(describing: param))
            }
            print("take time: \(endTime - startTime)")
            print ("======= response ======= \n\(String(describing: response))")
            
            AppDelegate.instance()?.stopIndicator()
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
                    self.errorDebugPring(result)
                }
                
                break
            case .failure(let error as NSError?):
                if let failure = failure {
                    failure(error)
                    self.errorDebugPring(error)
                }
                break
            }
        }
    }
    
    func requestIot(_ method: HTTPMethod, _ url: String, _ param:[String :Any]?, success:ResSuccess?, failure:ResFailure?) {
        
//        let headers: HTTPHeaders = [.accept(ContentType.json.rawValue)]
        let encodedUrl:String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let request = AF.request(encodedUrl, method: method, parameters: nil, encoding: JSONEncoding.default)
        let startTime = CACurrentMediaTime()
        request.responseJSON { (response:AFDataResponse<Any>) in
            
            let endTime = CACurrentMediaTime()
            if let url = response.request?.url?.absoluteString {
                print("\n\n =======request ======= \nurl: \(String(describing: url))")
            }
            print("take time: \(endTime - startTime)")
            print ("======= response ======= \n\(String(describing: response))")
             
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
    
    func errorDebugPring(_ data: Any?) {
        if let data = data as? [String : Any] {
            
            var title = "Error :"
            if let code = data["code"] as? Int {
                title.append(":\(code)")
            }
            var popupMsg = ""
            if let errors = data["errors"] as? [[String: Any]], errors.count > 0 {
                for error in errors {
                    if let field = error["field"] as? String, let message = error["message"] as? String {
                        popupMsg.append("\(field):\(message)\n")
                    }
                }
            }
            else if let msg = data["msg"] as? String {
                popupMsg = msg
            }
            
            if popupMsg.hasSuffix("\n") {
                popupMsg.remove(at: popupMsg.index(before: popupMsg.endIndex))
            }
            
            print("\(title): \(popupMsg)")
        }
    }
    
    func reqeustKakaoAddressSearch(_ keyword:String, success:ResSuccess?, failure:ResFailure?) {
        var headers: HTTPHeaders = [.accept(ContentType.json.rawValue)]
        let myHerder = HTTPHeader(name: "Authorization", value: "KakaoAK \(KAKAO_REST_API_KEY)")
        headers.add(myHerder)
        let parameters: [String: Any] = ["query": keyword, "page": 1, "size": 20 ]
        let url = "https://dapi.kakao.com/v2/local/search/address.json"
    
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { (response: AFDataResponse<Any>) in
            
            switch response.result {
            case .success(let value):
                let statusCode: Int = response.response!.statusCode as Int
                if (statusCode >= 200) && (statusCode <= 300) {
//                    print(String(describing: value))
                    guard let value = value as? [String:Any] else {
                        success?(nil)
                        return
                    }
                    guard let list = value["documents"] as? Array<Any> else {
                        success?(nil)
                        return
                    }
                    success?(list)
                    return
                }
                else {
                    failure?(value)
                }
                
                break
                
            case .failure(let error):
                failure?(error)
                break
            }
        }
    }
    private func generateDeptFirstAddr(addr: String) -> String {
        switch(addr) {
        case "서울":
            return "서울특별시"
        case "대전", "인천", "부산", "광주", "울산", "대구":
            return "\(addr)광역시"
        case "경기", "제주", "강원":
            return "\(addr)도"
        case "충남":
            return "충청남도"
        case "충북":
            return "충청북도"
        case "경남":
            return "경상남도"
        case "전남":
            return "전라남도"
        case "전북":
            return "전라북도"
        case "경북":
            return "경상북도"
        default:
            return "Unknown"
        }
    }
}
