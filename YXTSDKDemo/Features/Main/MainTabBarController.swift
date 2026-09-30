//
//  MainTabBarController.swift
//  YXTSDKDemo
//
//  授权后主界面 Tab：课堂、课程、作业、我的。商城暂不接入。
//

import UIKit
import PlasoCommonSDK
import PlasoLiveMini

/// 主 Tab 容器。全部使用 UIKit。
final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTabs()
        configureAppearance()
    }

    private func setupTabs() {
        let classroom: UIViewController
        if UIDevice.current.userInterfaceIdiom == .pad {
            let host = PadClassroomHostViewController()
            host.tabBarItem = makeTabItem(title: "课堂", systemImage: "video")
            classroom = host
        } else {
            classroom = wrap(
                makeClassroomRoot(),
                title: "课堂",
                systemImage: "video"
            )
        }
        let course = wrap(
            CourseViewController(),
            title: "课程",
            systemImage: "book"
        )
        let homework = wrap(
            HomeworkViewController(),
            title: "作业",
            systemImage: "square.and.pencil"
        )
        // let mall = wrap(
        //     MallViewController(),
        //     title: "商城",
        //     systemImage: "cart"
        // )
        let mine = wrap(
            MineViewController(),
            title: "我的",
            systemImage: "person"
        )
        let pages = [classroom, course, homework, mine]
        if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad {
            useSidebar(pages)
        } else {
            viewControllers = pages
        }
    }

    /// iPadOS 18 起，只有用 `tabs` 配置才会出现左侧侧边栏；用 `viewControllers` 会变成顶部浮动栏，
    /// 而且系统仍按看不见的底部栏把子页面减掉 50pt。
    @available(iOS 18.0, *)
    private func useSidebar(_ pages: [UIViewController]) {
        tabs = pages.enumerated().map { index, page in
            UITab(
                title: page.tabBarItem.title ?? "",
                image: page.tabBarItem.image,
                identifier: "tab.\(index)"
            ) { _ in page }
        }
        mode = .tabSidebar
        sidebar.isHidden = false
    }

    /// iPhone 的切换放在 `navigationItem.titleView`，必须作为导航根控制器。
    private func makeClassroomRoot() -> UIViewController {
        let classroom = PhoneClassroomViewController()
        classroom.liveClass = true
        classroom.forcePortrait = true
        classroom.showInviteJoin = true
        // 不透明导航栏下，列表不要延伸到标题下面，否则会挡住「实时课堂 / 历史课堂」
        classroom.edgesForExtendedLayout = []
        return classroom
    }

    private func wrap(
        _ root: UIViewController,
        title: String,
        systemImage: String
    ) -> UINavigationController {
        let nav = TabNavigationController(rootViewController: root)
        root.extendedLayoutIncludesOpaqueBars = true
        configureNavigationBar(nav)
        nav.tabBarItem = makeTabItem(title: title, systemImage: systemImage)
        return nav
    }

    private func makeTabItem(title: String, systemImage: String) -> UITabBarItem {
        UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImage),
            selectedImage: UIImage(systemName: systemImage)
        )
    }

    /// 白底导航栏仍保持 `isTranslucent = true`。
    /// `configureWithOpaqueBackground()` 会让系统把栏当成不透明，子页面高度被减掉 50pt。
    private func configureNavigationBar(_ nav: UINavigationController) {
        let bar = nav.navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.isTranslucent = true
    }

    private func configureAppearance() {
        tabBar.tintColor = UIColor(red: 0, green: 0.43, blue: 0.36, alpha: 1)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance
    }
}

/// iPhone 把「实时课堂 / 历史课堂」放在 `navigationItem.titleView`（210×33）。
/// 导航栏用 Auto Layout 排标题时会把这块压扁，右侧「历史课堂」就被挡住。
private final class PhoneClassroomViewController: YXTLiveClassiPhoneVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        pinHeader()
    }

    private func pinHeader() {
        guard let header = navigationItem.titleView else { return }
        header.translatesAutoresizingMaskIntoConstraints = false
        let hasWidth = header.constraints.contains { $0.firstAttribute == .width }
        if hasWidth {
            return
        }
        header.widthAnchor.constraint(equalToConstant: 210).isActive = true
        header.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
}

/// iPad 上导航栏会把子页面高度做成「容器 − 50」，少掉的部分空在底部。
/// 高度要在系统布局之后补上，并立刻让子页面按新高度再排一次，否则内部列表仍按短高度布局。
private final class TabNavigationController: YXTBaseNavigationVC {

    private var isFittingChild = false

    override func viewDidLayoutSubviews() {
        if !isFittingChild {
            super.viewDidLayoutSubviews()
        }
        fitChildToContainerBottom()
    }

    private func fitChildToContainerBottom() {
        guard !isFittingChild, UIDevice.current.userInterfaceIdiom == .pad else { return }
        guard let page = topViewController?.view, let container = page.superview else { return }
        let missing = container.bounds.maxY - page.frame.maxY
        guard missing > 0.5 else { return }
        isFittingChild = true
        page.frame.size.height += missing
        page.layoutIfNeeded()
        isFittingChild = false
    }
}

/// iPad 课堂自绘导航条贴在 `view` 顶部（再下移 20pt）。
/// 系统导航栏会盖住它，所以这一页不使用系统栏。内容用约束贴在安全区下面。
private final class PadClassroomHostViewController: UIViewController {

    private let classroom: YXTRealTimeMainVC = {
        let classroom = YXTRealTimeMainVC(userInfo: [:])
        classroom.needNavigationBack = false
        return classroom
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addChild(classroom)
        classroom.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(classroom.view)
        NSLayoutConstraint.activate([
            classroom.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            classroom.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            classroom.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            classroom.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        classroom.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logLayoutIfChanged(stage: "system")
        extendHostToSuperviewBottom()
    }

    private var isExtending = false

    /// 兜底：iPadOS 18 旧的底部 tab bar 已不在层级里，系统仍按它把本页减掉 50pt，底部留空。
    /// 此时把高度补到父视图底部。
    private func extendHostToSuperviewBottom() {
        guard !isExtending, let superview = view.superview else { return }
        let missing = superview.bounds.maxY - view.frame.maxY
        guard abs(view.frame.minY) < 0.5, missing > 0.5 else { return }
        #if DEBUG
        NSLog("[YXTSDKDemo][PadLayout] 兜底补高 %.1f", missing)
        #endif
        isExtending = true
        view.frame.size.height += missing
        view.layoutIfNeeded()
        isExtending = false
        logLayoutIfChanged(stage: "extended")
    }

    #if DEBUG
    private var lastLoggedLayout = ""
    #endif

    private func logLayoutIfChanged(stage: String) {
        #if DEBUG
        let tabBar = tabBarController?.tabBar
        let chain = sequence(first: view as UIView, next: { $0.superview })
            .prefix(4)
            .map { "\(type(of: $0))\($0.frame)" }
            .joined(separator: " <- ")
        let summary = """
        parent=\(parent.map { "\(type(of: $0))" } ?? "nil") \
        chain=\(chain) \
        safeArea=\(view.safeAreaInsets) \
        classroom=\(classroom.view.frame) \
        tabBar=\(tabBar.map { describe(tabBar: $0) } ?? "nil")
        """
        guard summary != lastLoggedLayout else { return }
        lastLoggedLayout = summary
        NSLog("[YXTSDKDemo][PadLayout][%@] iOS %@ %@", stage, UIDevice.current.systemVersion, summary)
        #endif
    }

    #if DEBUG
    private func describe(tabBar: UITabBar) -> String {
        let onScreen = tabBar.window.map { tabBar.convert(tabBar.bounds, to: $0) }
        var mode = "legacy"
        if #available(iOS 18.0, *), let tabs = tabBarController {
            mode = "mode=\(tabs.mode.rawValue) sidebarHidden=\(tabs.sidebar.isHidden) tabBarHidden=\(tabs.isTabBarHidden)"
        }
        return "\(mode) \(tabBar.frame) hidden=\(tabBar.isHidden) alpha=\(tabBar.alpha) "
            + "superview=\(tabBar.superview.map { "\(type(of: $0))" } ?? "nil") "
            + "inWindow=\(onScreen.map { "\($0)" } ?? "nil") "
            + "sizeClass=\(traitCollection.horizontalSizeClass.rawValue)"
    }
    #endif
}
