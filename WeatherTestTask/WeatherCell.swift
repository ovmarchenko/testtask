//
//  WeatherCell.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/31/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherCell: UITableViewCell {
    private var disposeBag = DisposeBag()
    private static let temperatureFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        
        return formatter
    }()

    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet private var conditionLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    func configure(iconID: String, cityName: String, condition: String, temperature: Measurement<UnitTemperature>) {
        cityNameLabel.text = cityName
        conditionLabel.text = condition
        temperatureLabel.text = WeatherCell.temperatureFormatter.string(for: temperature)

        IconManager.icon(id: iconID).drive(iconImageView.rx.image).disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
