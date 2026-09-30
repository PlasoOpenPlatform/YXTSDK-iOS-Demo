//
//  SplashView.swift
//  YXTSDKDemo
//
//  启动页（SwiftUI）。
//

import SwiftUI

/// 启动闪屏。展示品牌后进入授权或主页。
struct SplashView: View {

    @ObservedObject var viewModel: SplashViewModel

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                Text("YXT SDK Demo")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0, green: 0.43, blue: 0.36))
                Text("伯索云课堂 SDK 接入示例")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear {
            viewModel.start()
        }
    }
}
