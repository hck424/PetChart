//
//  ApiManager.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

class ApiManager: NSObject {
    static let shared = ApiManager()
    
   ///로그인
    func requestUserSignIn(param: [String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/signin", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///회원가입
    func requestUserSignOut(param:[String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/signup", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///회원탈퇴
    func requestUserExit(param:[String: Any], success: ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.delete, "/api/v1/user", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///아이디 중복체크 ex){ "search": "test@test.com"}
    func requestFindUserIdCheck(id:String, success:ResSuccess?, failure: ResFailure?) {
        let param = ["search": id]
        NetworkManager.shared.request(.post, "/api/v1/findById", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///닉네임 중복 체크 ex){"search": "도담이"}
    func requestFindUserNicNameCheck(nickName: String, success:ResSuccess?, failure: ResFailure?) {
        let param = ["search": nickName]
        NetworkManager.shared.request(.post, "/api/v1/findByNickname", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///비밀번호 찾기
    func requestFindUserPassword(param:[String : Any], success:ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/findByPass", nil) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///회원 정보 조회
    func requestGetUserInfo(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/user/info", nil) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///X-AUTH-TOKEN 갱신
    func requestUpdateAuthToken(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/user/updateAuthToken" , param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///내정보 변경
    func requestModifyUserInfo(param:[String: Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/user/changeByInfo" , param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///비밀번호 변경
    func requestModifyPassword(param:[String: Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/user/changeByPass" , param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }

    ///마이펫 리스트
    func requestMyPetList(success: ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/animal/lists", nil) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    
    ///IOT Conented
    func requestIotConnet(success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/connect?apiKey=\(IOT_API_KEY)"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///IOT Setting
    func requestIotSetting(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        var url = "\(IOT_SERVER_PREFIX)/iot/set/setting?"
        url.append("idx=\(param["idx"]!)")
        url.append("&sessionKey=\(param["sessionKey"]!)")
        url.append("&uid=\(param["uid"]!)")
        url.append("&url=\(param["url"]!)")
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    func requestIotStation(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        var url = "\(IOT_SERVER_PREFIX)/iot/set/station?"
        url.append("ssid=\(param["ssid"]!)")
        url.append("&passwordKey=\(param["passwordKey"]!)")
        url.append("&sessionKey=\(param["sessionKey"]!)")
        url.append("&timestamp=\(param["timestamp"]!)")
        
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///IOT 장비 상태
    func requestIotStatus(success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/get/status"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// IOT 서비스 시작 /iot/set/service_start
    func requestIotServiceStart(sessionKey:String, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/service_start?sessionKey=\(sessionKey)"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///IOT 서비스 중지 /iot/set/service_stop
    func requestIotServiceStop(sessionKey:String?, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/service_stop"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///IOT 초기화 /iot/set/reset
    func requestIotReset(sessionKey:String?, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/reset"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    /// APP -> Iot 연결 해지 /iot/set/disconnect
    func requestIotDisConnet(sessionKey:String?, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/disconnect"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
}
