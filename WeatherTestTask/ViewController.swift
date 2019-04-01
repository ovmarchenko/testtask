//
//  ViewController.swift
//  IntelityTestTask
//
//  Created by Oleksandr Marchenko on 3/30/19.
//  Copyright © 2019 Oleksandr Marchenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var reloadImageButton: UIButton!

    @IBOutlet private var errorViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var errorView: UIView!
    @IBOutlet private var errorViewLabel: UILabel!

    private let disposeBag = DisposeBag()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        Model.shared.latestWeather.bind(to: tableView.rx.items(cellIdentifier: "default", cellType: WeatherCell.self)) { index, model, cell in
            cell.configure(iconID: model.iconID, cityName: model.cityName, condition: model.description, temperature: model.temperature)
        }.disposed(by: disposeBag)

        Model.shared.isLoading.filter { $0 == true }.subscribe(onNext: { [weak self] _ in
            self?.toggleLoadingAnimation(on: true)
            self?.tableView.refreshControl?.beginRefreshing()
        }).disposed(by: disposeBag)

        Model.shared.isLoading.filter { $0 == false }.debounce(1, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            self?.toggleLoadingAnimation(on: false)
            self?.tableView.refreshControl?.endRefreshing()
        }).disposed(by: disposeBag)

        if let imageView = reloadImageButton.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        }
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)

        Model.shared.latestWeather
        .filter { !$0.isEmpty }
        .map { $0.first!.date }
        .map { [weak self] in
            let dateString = self?.dateFormatter.string(from: $0) ?? "-"
            return "Offline mode. This weather was actual at \(dateString)"
        }.bind(to: errorViewLabel.rx.text)
        .disposed(by: disposeBag)
    }

    @IBAction @objc func reload() {
        Model.shared.updateWeather().subscribe(onCompleted: { [weak self] in
            self?.toggleErrorView(on: false, animated: true)
        },
        onError: { [weak self] _ in
            self?.toggleErrorView(on: true, animated: true)
        }).disposed(by: disposeBag)
    }

    func toggleErrorView(on: Bool, animated: Bool) {
        errorViewTopConstraint.constant = on ? 0.0 : -errorView.frame.height

        if animated {
            UIView.animate(withDuration: 0.75) {
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.flashScrollIndicators()
        reload()
    }

    func toggleLoadingAnimation(on: Bool) {
        guard on else {
            reloadImageButton.imageView!.layer.removeAllAnimations()
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1.5
        animation.repeatCount = .greatestFiniteMagnitude

        reloadImageButton.imageView!.layer.add(animation, forKey: nil)
    }

}

