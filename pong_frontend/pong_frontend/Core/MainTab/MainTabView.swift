//
//  MainTabView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

enum Tabs: String {
    case feed
    case messages
    case profile
}

struct MainTabView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
            TabView {
                NavigationView {
                    FeedView()
                        .toolbar{
                            ToolbarItem(placement: .principal) {
                                Text("Harvard")
                                    .font(.title.bold())
                            }
                            
                            ToolbarItem(){
                                NavigationLink {
                                    LeaderboardView()
                                } label: {
                                    Image(systemName: "chart.bar.fill")
                                }
                                .padding()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }.tabItem{Image(systemName: "house")}
                NavigationView {
                    MessagesView()
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Messages")
                                    .font(.title.bold())
                            }
                            
                            ToolbarItem(){
                                NavigationLink {
                                    NewChatView()
                                } label: {
                                    Image(systemName: "plus.message.fill")
                                }
                                .padding()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }.tabItem{Image(systemName: "envelope")}
                
                NavigationView {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Me")
                                    .font(.title.bold())
                            }
                            
                            ToolbarItem(){
                                Button {
                                    withAnimation(.easeInOut) {
                                        showSettings.toggle()
                                    }
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                }
                                .padding()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }.tabItem{Image(systemName: "person")}
            }
            .onAppear {
                // correct the transparency bug for Tab bars
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                // correct the transparency bug for Navigation bars
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.configureWithOpaqueBackground()
                UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            }
    }
}

//struct MainTabView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        MainTabView(showSettings: false)
//    }
//}
