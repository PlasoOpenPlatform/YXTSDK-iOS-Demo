//
//  HomeworkViewController.swift
//  YXTSDKDemo
//
//  作业（巩固）Tab：嵌入 SDK YXTNewHomeworkVC。
//

import UIKit
import PlasoFeatureWeb

/// 作业页容器，嵌入巩固列表。
final class HomeworkViewController: UIViewController {

    private let viewModel = HomeworkViewModel()
    private var homeworkVC: YXTNewHomeworkVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "作业"
        embedHomework()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extendToContainerBottom()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        extendToContainerBottom()
    }

    private var isExtending = false

    /// 导航控制器把本页放在栏下，高度仍少一个栏高。补到父视图底部。
    /// 课程、商城作为导航根页面，由 `TabNavigationController` 做同样的补高。
    private func extendToContainerBottom() {
        guard !isExtending, let superview = view.superview else { return }
        let missing = superview.bounds.maxY - view.frame.maxY
        if missing > 0.5 {
            isExtending = true
            view.frame.size.height += missing
            view.layoutIfNeeded()
            isExtending = false
        }
        pinWebViewToHost()
    }

    /// SDK 按状态栏把 webView 下移 20/44pt。本页已经贴在安全区下面，这段空白会留在底部。
    private func pinWebViewToHost() {
        guard let webView = homeworkVC?.webView, let host = webView.superview else { return }
        let gap = host.bounds.maxY - webView.frame.maxY
        guard webView.frame.minY > 0.5 || gap > 0.5 else { return }
        let pins = host.constraints.filter {
            ($0.firstItem as? UIView) === webView || ($0.secondItem as? UIView) === webView
        }
        NSLayoutConstraint.deactivate(pins)
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.frame = host.bounds
    }

    private func embedHomework() {
        let child = YXTNewHomeworkVC()
        homeworkVC = child
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
        // 部分版本需主动触发加载。不传 withBack，Tab 根页面不显示返回。
        child.startLoadWeb([:])
        viewModel.didEmbed = true
    }
}
