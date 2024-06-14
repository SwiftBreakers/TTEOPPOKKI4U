//
//  MapVIewModel.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/29/24.
//

import Foundation


class MapViewModel {
    // View에서 이벤트를 발생시켜서 viewModel INPUT으로 전달

    // input
    // - 지도 화면 진입할 때
    // - searchBar에서 Enter 눌렀을 때 : searchBar.text
    // - annotation pin 눌렀을 때 : storeList에서 클릭한 pin의 타이틀과 같은 데이터
    // - scrapButton 눌렀을 때
    // - 매장명 눌렀을 때
    // - 친구찾기 버튼 눌렀을 때
    
    // ViewModel은 INPUT을 받아서 실질적인 작업을 한다음에 OUTPUT을 업데이트함
    
    // output
    // view에 보여져야할 데이터들.
    // - 내 위치 기반으로 한 지도 화면
    // - storeList
    // - Pinstoreview 데이터 채워져서 나타나야 함
    // - scrapButton 누를 때마다 색깔 달라져야 함(firebase 관리는 viewmodel에서)
    // - 가게 상세 페이지로 이동
    // - 채팅방 페이지로 이동(아직 구현 안 됨)
    
    // View는 ViewModel의 Output을 옵저브(구경)하고 있다가 데이터가 바뀌면 View를 업데이트 해줌.
}

