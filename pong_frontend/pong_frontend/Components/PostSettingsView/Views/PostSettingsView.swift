//
//  SettingsSheetView.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/12/22.
//

import SwiftUI
import GoogleSignIn

struct PostSettingsView: View {
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(PostSettingsOptionsViewModel.allCases, id: \.rawValue) { viewModel in
                        if viewModel == .save {
                            Button {
                                postSettingsVM.savePostAlamofire()
                            } label: {
                                PostSettingsRowView(viewModel: viewModel)
                            }
                        } else if viewModel == .block {
                            Button {
                                postSettingsVM.blockUserAlamofire()
                            } label: {
                                PostSettingsRowView(viewModel: viewModel)
                            }
                        } else if viewModel == .report {
                            Button {
                                postSettingsVM.reportPostAlamofire()
                            } label: {
                                PostSettingsRowView(viewModel: viewModel)
                            }
                        } else {
                            PostSettingsRowView(viewModel: viewModel)
                        }
                    }
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PostSettings_Previews: PreviewProvider {
    static var previews: some View {
        PostSettingsView(postSettingsVM: PostSettingsViewModel())
    }
}
