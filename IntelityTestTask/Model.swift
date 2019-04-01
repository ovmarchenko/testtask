//
//  Model.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/31/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

class Model {
    private var foreverBag = DisposeBag()
    private var requestBag = DisposeBag()

    private var weatherSubject = BehaviorSubject(value: DiskCache.shared.cachedWeather() ?? [])

    private init() {
        weatherSubject.subscribe( onNext: { weather in
            DiskCache.shared.saveWeather(weather)
        }).disposed(by: foreverBag)
    }

    static let shared = Model()

    var latestWeather: Observable<[Weather]> {
        return weatherSubject
    }

    private let isLoadingSubject = BehaviorSubject(value: false)

    var isLoading: Observable<Bool> {
        return isLoadingSubject.distinctUntilChanged().observeOn(MainScheduler.instance)
    }

    func updateWeather() -> Completable {
        requestBag = DisposeBag()

        let weatherRequest = OpenWeatherAPI.fetchWeather(for: CityID.allCases).share()

        weatherRequest.do { [unowned self] in
            self.isLoadingSubject.onNext(false)
        }
        .subscribe(onNext: { [unowned self] weather in
            self.weatherSubject.onNext(weather)
        }).disposed(by: requestBag)

        isLoadingSubject.onNext(true)

        return weatherRequest.observeOn(MainScheduler.instance).ignoreElements()
    }
}


