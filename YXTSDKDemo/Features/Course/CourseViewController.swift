//
//  CourseViewController.swift
//  YXTSDKDemo
//
//  课程 Tab：嵌入 SDK MyCourseViewController。
//

import UIKit
import PlasoFeatureWeb

/// 课程页容器，嵌入学生端「我的课程」。
final class CourseViewController: UIViewController {

    private let viewModel = CourseViewModel()
    private var courseVC: MyCourseViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "课程"
        embedCourse()
    }

    private func embedCourse() {
        let child = MyCourseViewController()
        courseVC = child
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
        // 部分版本需主动触发加载
        child.startLoadWeb([:])
        viewModel.didEmbed = true
    }
}
