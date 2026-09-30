//
//  AuthConfigView.swift
//  YXTSDKDemo
//
//  授权配置页（SwiftUI）。
//

import SwiftUI
import UIKit

/// 授权配置：环境、AppId、SignKey、用户名、用户类型。
struct AuthConfigView: View {

    @ObservedObject var viewModel: AuthConfigViewModel

    var body: some View {
        Form {
            Section(header: Text("服务器")) {
                NavigationLink(destination: EnvironmentListView(
                    current: viewModel.form.environment,
                    onSelect: { viewModel.selectEnvironment($0) }
                )) {
                    HStack {
                        Text("服务器环境")
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.form.environment.displayName)
                                .foregroundColor(.secondary)
                            Text(viewModel.form.environment.host)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section(header: Text("开放平台凭证"), footer: Text("SignKey 仅用于 Demo 演示。正式环境请在服务端签名，勿将密钥打入客户端包。")) {
                TextField("AppId", text: $viewModel.form.appId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                SecureField("SignKey", text: $viewModel.form.signKey)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            Section(header: Text("用户"), footer: Text("调用 OpenAPI /user/getToken，无需密码。")) {
                TextField("用户名（loginName）", text: $viewModel.form.loginName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Picker("用户类型", selection: $viewModel.form.userType) {
                    ForEach(UserType.allCases, id: \.rawValue) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                }
            }

            Section {
                Button(action: {
                    hideKeyboard()
                    viewModel.submit()
                }) {
                    HStack {
                        Spacer()
                        Text(viewModel.isLoading ? "授权中..." : "登录授权")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationBarTitle(Text("授权配置"), displayMode: .inline)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
