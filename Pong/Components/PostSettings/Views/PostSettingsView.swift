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
                    if postSettingsVM.post.saved == true {
                        Button {
                            postSettingsVM.savePostAlamofire()
                        } label: {
                            PostSettingsRowView(viewModel: PostSettingsOptionsViewModel.saved)
                        }
                    }
                    else {
                        Button {
                            postSettingsVM.savePostAlamofire()
                        } label: {
                            PostSettingsRowView(viewModel: PostSettingsOptionsViewModel.save)
                        }
                    }
                    Button {
                        DispatchQueue.main.async {
                            postSettingsVM.showDeleteConfirmationView.toggle()
                        }
                    } label: {
                        PostSettingsRowView(viewModel: PostSettingsOptionsViewModel.report)
                    }
                    Button {
                        postSettingsVM.blockUserAlamofire()
                    } label: {
                        PostSettingsRowView(viewModel: PostSettingsOptionsViewModel.block)
                    }
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal, 20)
            }
        }
    }
    
    func remove(at offsets: IndexSet) {
        withAnimation {
            
        }
    }
}

struct PostSettings_Previews: PreviewProvider {
    static var previews: some View {
        PostSettingsView(postSettingsVM: PostSettingsViewModel())
    }
}
