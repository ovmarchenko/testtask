//
//  IconManager.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/31/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class IconManager {
    private static let foreverBag = DisposeBag()

    static func icon(id: String) -> Driver<UIImage?> {
        if let image = DiskCache.shared.cachedIcon(id: id) {
            return .just(image)
        }

        let iconRequest = OpenWeatherAPI.fetchIcon(id: id)
            .observeOn(MainScheduler.instance).share()

        iconRequest.filter { $0 != nil }.subscribe(onNext: { image in
            DiskCache.shared.saveIcon(image!, id: id)
        }).disposed(by: foreverBag)

        return iconRequest.asDriver(onErrorJustReturn: nil)
    }
}
