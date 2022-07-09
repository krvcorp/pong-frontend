//
//  BannerViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/9/22.
//

import Foundation

class BannerViewModel: ObservableObject {
    @Published var showBanner : Bool = false
    @Published var bannerData : BannerModifier.BannerData = BannerModifier.BannerData(title: "NotificationTitle", detail: "NotificationText.", type: .Warning)

    
}
