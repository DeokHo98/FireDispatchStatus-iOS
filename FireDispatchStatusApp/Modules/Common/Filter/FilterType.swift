//
//  FilterType.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 12/3/24.
//

import Foundation

extension FilterFeature {
    enum FilterType: String {
        case region = "지역"
        case state = "상태"
        
        var items: [String] {
            switch self {
            case .region:
                return [
                    "전체", "서울", "광주", "부산", "대구", "인천", "울산", "세종", "경기",
                    "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"
                ]
            case .state:
                return [
                    "전체", "화재접수", "화재출동",
                    "현장도착", "귀소", "잔불감시"
                ]
            }
        }
    }
}
