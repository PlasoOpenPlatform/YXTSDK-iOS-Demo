//
//  EnvironmentListView.swift
//  YXTSDKDemo
//
//  服务器环境二级选择列表。
//

import SwiftUI

/// 环境选择二级页。选中后回调并返回。
struct EnvironmentListView: View {

    let current: ServerEnvironment
    let onSelect: (ServerEnvironment) -> Void
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            ForEach(ServerEnvironment.allCases, id: \.rawValue) { env in
                Button(action: {
                    onSelect(env)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(env.displayName)
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .medium))
                            Text(env.host)
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                        }
                        Spacer()
                        if env == current {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 0, green: 0.43, blue: 0.36))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationBarTitle(Text("服务器环境"), displayMode: .inline)
        .listStyle(GroupedListStyle())
    }
}
