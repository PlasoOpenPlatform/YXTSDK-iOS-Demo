//
//  MallViewController.swift
//  YXTSDKDemo
//
//  商城 Tab：嵌入 SDK YXTEduMarketVC。
//

import UIKit
import PlasoFeatureWeb

/// 商城页容器，嵌入教育超市。
final class MallViewController: UIViewController {

    private let viewModel = MallViewModel()
    private var marketVC: YXTEduMarketVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "商城"
        embedMarket()
    }

    private func embedMarket() {
        let child = YXTEduMarketVC()
        marketVC = child
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        child.didMove(toParent: self)
        viewModel.didEmbed = true
    }
}
