//
//  SettingsView.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/12/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginVM : LoginViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            
            ForEach(SettingsViewModel.allCases, id: \.rawValue) { viewModel in
                if viewModel == .account {
                    Button {
                        print("DEBUG: SIGN OUT")
                    } label: {
                        SettingsOptionRowView(viewModel: viewModel)
                    }
                } else if viewModel == .logout {
                    Button {
                        print("DEBUG: SIGN OUT")
                        loginVM.signout()
                    } label: {
                        SettingsOptionRowView(viewModel: viewModel)
                    }
                    
                } else {
                    SettingsOptionRowView(viewModel: viewModel)
                }
            }
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}


