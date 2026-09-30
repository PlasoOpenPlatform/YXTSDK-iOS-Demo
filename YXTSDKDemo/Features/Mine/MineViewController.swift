//
//  MineViewController.swift
//  YXTSDKDemo
//
//  「我的」页（自建 UIKit）。
//

import UIKit

/// 展示当前用户与会话信息，支持退出登录。
final class MineViewController: UIViewController {

    private let viewModel = MineViewModel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var items: [MineViewModel.ProfileItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
        view.backgroundColor = .white
        setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
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
    private func extendToContainerBottom() {
        guard !isExtending, let superview = view.superview else { return }
        let missing = superview.bounds.maxY - view.frame.maxY
        guard missing > 0.5 else { return }
        isExtending = true
        view.frame.size.height += missing
        view.layoutIfNeeded()
        isExtending = false
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func reload() {
        items = viewModel.makeItems()
        tableView.reloadData()
    }
}

extension MineViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? items.count : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "账号信息" : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        if indexPath.section == 0 {
            let item = items[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(item.title)：\(item.value)"
            cell.textLabel?.textColor = .darkText
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = "退出登录"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        let alert = UIAlertController(
            title: "确认退出？",
            message: "退出后需重新授权登录",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "退出", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.logout()
        }))
        present(alert, animated: true)
    }
}
