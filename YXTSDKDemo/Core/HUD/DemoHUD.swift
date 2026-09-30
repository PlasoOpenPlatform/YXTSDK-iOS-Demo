//
//  DemoHUD.swift
//  YXTSDKDemo
//
//  自绘 Loading / Toast，不依赖第三方 HUD 库。
//

import UIKit

/// 简单 HUD：全屏半透明遮罩 + 指示器 / 文本提示。
enum DemoHUD {

    private static var overlay: UIView?
    private static var toastLabel: UILabel?

    /// 在指定视图上显示 Loading
    static func showLoading(on view: UIView? = nil, text: String = "加载中...") {
        DispatchQueue.main.async {
            hideLoading()
            guard let host = view ?? keyWindow() else { return }

            let container = UIView(frame: host.bounds)
            container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            container.tag = 9_901

            let box = UIView()
            box.backgroundColor = UIColor.black.withAlphaComponent(0.78)
            box.layer.cornerRadius = 10
            box.translatesAutoresizingMaskIntoConstraints = false

            let indicator = UIActivityIndicatorView(style: .whiteLarge)
            indicator.startAnimating()
            indicator.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            box.addSubview(indicator)
            box.addSubview(label)
            container.addSubview(box)
            host.addSubview(container)

            NSLayoutConstraint.activate([
                box.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                box.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                box.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                box.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
                indicator.centerXAnchor.constraint(equalTo: box.centerXAnchor),
                indicator.topAnchor.constraint(equalTo: box.topAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -16)
            ])

            overlay = container
        }
    }

    /// 隐藏 Loading
    static func hideLoading() {
        DispatchQueue.main.async {
            overlay?.removeFromSuperview()
            overlay = nil
            keyWindow()?.viewWithTag(9_901)?.removeFromSuperview()
        }
    }

    /// 显示短暂 Toast
    static func showToast(_ message: String, duration: TimeInterval = 1.8) {
        DispatchQueue.main.async {
            guard let host = keyWindow() else { return }
            toastLabel?.removeFromSuperview()

            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false

            host.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: host.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor, constant: -60),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: host.leadingAnchor, constant: 32),
                label.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor, constant: -32),
                label.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
            ])
            label.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            // 内边距通过 content hugging 近似
            label.setContentHuggingPriority(.required, for: .vertical)

            toastLabel = label
            UIView.animate(withDuration: 0.2, animations: {
                label.alpha = 1
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.25, animations: {
                    label.alpha = 0
                }, completion: { _ in
                    label.removeFromSuperview()
                    if toastLabel === label {
                        toastLabel = nil
                    }
                })
            }
        }
    }

    private static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
                ?? UIApplication.shared.windows.first
        }
        return UIApplication.shared.keyWindow
    }
}
