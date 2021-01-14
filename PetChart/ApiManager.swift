//
//  ApiManager.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/29.
//

import UIKit

class ApiManager: NSObject {
    static let shared = ApiManager()
    //FIXME::IOT
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
        var url = "\(IOT_SERVER_PREFIX)/iot/set/settting?"
        url.append("url=\(param["url"]!)")
        url.append("&idx=\(param["idx"]!)")
        url.append("&sessionKey=\(param["sessionKey"]!)")
        url.append("&uid=\(param["uid"]!)")
        
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    func requestIotStation(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        var url = "\(IOT_SERVER_PREFIX)/iot/set/station?"
        url.append("sessionKey=\(param["sessionKey"]!)")
        url.append("&ssid=\(param["ssid"]!)")
        url.append("&passwordKey=\(param["passwordKey"]!)")
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
    func requestIotServiceStop(sessionKey:String, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/service_stop?sessionKey=\(sessionKey)"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///IOT 초기화 /iot/set/reset
    func requestIotReset(sessionKey:String, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/reset?sessionKey=\(sessionKey)"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    /// APP -> Iot 연결 해지 /iot/set/disconnect
    func requestIotDisConnet(sessionKey:String, success:ResSuccess?, failure:ResFailure?) {
        let url = "\(IOT_SERVER_PREFIX)/iot/set/disconnect?sessionKey=\(sessionKey)"
        NetworkManager.shared.requestIot(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    //FIXME:: App Server Api
    ///배너리스트 요청
    func requestBannerList(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/app/banner", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
   ///로그인
    func requestUserSignIn(param: [String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/signin", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///회원가입
    func requestUserSignUp(param:[String : Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/signup", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///회원탈퇴
    func requestUserExit(param:[String: Any], success: ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/user/delete", param) { (respone) in
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
        NetworkManager.shared.request(.post, "/api/v1/findByPass", param) { (respone) in
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
    ///비밀번호 변경 (로그인 안하고 비밀번호 변경 api)
    func requestModifyPassword(param:[String: Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/changeByPass", param) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }

    ///마이펫 리스트
    func requestMyPetList(success: ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/animal", nil) { (respone) in
            success?(respone)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///메인노출 여부
    func requestPetMainEnable(param: [String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.patch, "/api/v1/animal/mainEnable", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///펫 상세
    func requestPetDetailInfo(petId: Int, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/animal/\(petId)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    
    /// Config 정보
    func requestAppConfig(isMemoryCache:Bool = false, success: ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/app/config", nil) { (response) in
            if let response = response as? [String:Any], let data = response["data"] as? [String:Any] {
                success?(response)
            }
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///품종리스트
    func requestAnimalKinds(dtype:String, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/animal/kinds?kind=\(dtype)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///마이펫 등록
    func requestRegistAnimal(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/animal/create", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///펫 수정
    func requestPetInfoModify(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.patch, "/api/v1/animal", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///오늘 메인 데이터 노출 /api/v1/main/today/{pid}
    func requestTodayMainData(petId:Int, success:ResSuccess?, failure: ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/main/today/\(petId)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///BBS 리스트
    func requestTalkList(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        var url = "/api/v1/bbs?"
        var index = 0
        for (key, value) in param {
            if index == 0 {
                url.append("\(key)=\(value)")
            }
            else {
                url.append("&\(key)=\(value)")
            }
            index += 1
        }
        
        NetworkManager.shared.request(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///Like 좋아요 투표
    func requestChangeTalkLikeSate(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/bbs/like", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///Report 경고
    func requestPostReport(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/bbs/report", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///BBS 상세
    func requestTalkDetail(pId:Int, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/bbs/\(pId)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }

    }
    
    ///댓글 등록
    func requestWritePostComment(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/bbs/comments", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///댓글 삭제
    func requestDeltePostComment(comentId:Int, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.delete, "/api/v1/bbs/comments/\(comentId)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///게시글 등록
    func requestWritePost(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/bbs/upload", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///내 게시글 삭제
    func requestDeletePost(postId:Int, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.delete, "/api/v1/bbs/\(postId)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///내게시글 변경
    func requestModifyMyPost(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.patch, "/bbs/upload", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///FAQ 리스트
    func requestFAQList(group:String, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/faq?group=\(group)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///공지사항 리스트
    func requestNoticeList(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/notices", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///문의하기 리스트
    func requestContactChartList(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/contactChat", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///문의하기 Write
    func requestWriteContactChart(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/contactChat", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///약관
    func requestTerms(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/app/terms", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///차트 음수, 식사, 체중, 배변, 산책, 진료
    func requestChartData(health:PetHealth, petId:Int, type:GraphType, stDate:String, edDate:String, success:ResSuccess?, failure:ResFailure?) {
        var url = ""
        if health == .drink {
            url = "/api/v1/charts/drink?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        else if health == .eat {
            url = "/api/v1/charts/eat?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        else if health == .weight {
            url = "/api/v1/charts/weight?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        else if health == .feces {
            url = "/api/v1/charts/catharsis?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        else if health == .walk {
            url = "/api/v1/charts/walk?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        else if health == .medical {
            url = "/api/v1/charts/diagnosis?pet_id=\(petId)&searchType=\(type.rawValue)&beginDate=\(stDate)&endDate=\(edDate)"
        }
        
        if url.isEmpty == true {
            failure?(nil)
            return
        }
        
        NetworkManager.shared.request(.get, url, nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    
    ///차트 음수, 식사, 체중, 배변, 산책, 진료
    func requestWriteChart(type:PetHealth, param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        
        var url = ""
        if type == .drink {
            url = "/api/v1/animal/drink"
        }
        else if type == .eat {
            url = "/api/v1/animal/eat"
        }
        else if type == .weight {
            url = "/api/v1/animal/weight"
        }
        else if type == .feces {
            url = "/api/v1/animal/catharsis"
        }
        else if type == .walk {
            url = "/api/v1/animal/walk"
        }
        else if type == .medical {
            url = "/api/v1/animal/diagnosis"
        }
        
        if url.isEmpty == true {
            failure?(nil)
            return
        }
        NetworkManager.shared.request(.post, url, param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    //Iot 장비리스트
    func requetDeviceList(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/device", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    //Iot 장비 이름 변경
    func requetModifyDeviceName(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.patch, "/api/v1/device", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    //Iot 장비 삭제
    func requestDeleteDevice(pid:String, success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.delete, "/api/v1/device/\(pid)", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///Social 가입존재 여부
    func requestValidSocialLogin(param:[String:Any],success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/validSocial", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    ///FCM 갱신 /api/v1/app/updateFcmToken
    func requestUpdateFcmToken(param:[String:Any] ,success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.patch, "/api/v1/app/updateFcmToken", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 개월수 리스트
    func requestAnimalBirthdayMonthList(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/animal/birthMonth", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 푸쉬 알림 상태 조회
    func requestPushState(success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.get, "/api/v1/user/notification", nil) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 푸쉬 알림 설정 등록삭제
    func requestPushSetting(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.requestFormdataType(.post, "/api/v1/user/notification", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
    /// 앱 버전 정보
    func requestAppVersionInfo(param:[String:Any], success:ResSuccess?, failure:ResFailure?) {
        NetworkManager.shared.request(.post, "/api/v1/app/ver", param) { (response) in
            success?(response)
        } failure: { (error) in
            failure?(error)
        }
    }
}
