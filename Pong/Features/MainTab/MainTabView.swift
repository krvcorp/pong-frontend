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
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @ObservedObject var feedVM : FeedViewModel
    // tab selection
    @State private var tabSelection : Tabs = .feed
    
    var handler: Binding<Tabs> { Binding(
        get: { self.tabSelection },
        set: {
            // add some logic here that checks if the user is scrolled to the top
            // if the user is not scrolled to the top, just scroll to the top
            // if the user is scrolled to the top, activate pull to refresh
            if $0 == .feed {
                print("Refresh Home!")
                feedVM.getPosts(selectedFilter: .top)
                feedVM.getPosts(selectedFilter: .hot)
                feedVM.getPosts(selectedFilter: .recent)
            }
            self.tabSelection = $0
        }
    )}
    
    var body: some View {
        NavigationView {
            TabView(selection: handler) {
                FeedView(school: "Harvard", selectedFilter: .hot, feedVM: feedVM, postSettingsVM: postSettingsVM)
                .tabItem{Image(systemName: "house")}
                .tag(Tabs.feed)

                MessagesView()
                .tabItem{Image(systemName: "envelope")}
                .tag(Tabs.messages)

                ProfileView(settingsSheetVM: settingsSheetVM, postSettingsVM: postSettingsVM)
                .tabItem{Image(systemName: "person")}
                .tag(Tabs.profile)
            }
            // this bad boy is the toolbar
            .toolbar {
                // toolbar item in the left
                ToolbarItem(placement: .navigationBarLeading) {
                    if self.tabSelection == .feed {
                        NavigationLink {
                            ChooseLocationView()
                        } label: {
                            Text("Harvard")
                                .font(.title.bold())
                                .foregroundColor(Color(UIColor.label))
                        }
                    } else if self.tabSelection == .messages {
                    }
                }
                
                // toolbar item in the center
                ToolbarItem(placement: .principal) {
                    if self.tabSelection == .profile {
                        Text("Me")
                            .font(.title.bold())
                    } else if self.tabSelection == .messages {
                        Text("Messages")
                            .font(.title.bold())
                    }
                }
                
                // toolbar item on the right
                ToolbarItem(){
                    if self.tabSelection == .feed {
                        NavigationLink {
                            LeaderboardView()
                        } label: {
                            Image(systemName: "chart.bar.fill")
                        }
                        .padding()
                    } else if self.tabSelection == .messages {
                        NavigationLink {
                            NewChatView()
                        } label: {
                            Image(systemName: "plus.message.fill")
                        }
                        .padding()
                    } else if self.tabSelection == .profile {
                        Button {
                            withAnimation(.easeInOut) {
                                settingsSheetVM.showSettingsSheetView.toggle()
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .padding()
                    }

                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            tabBarAppearance.backgroundColor = .tertiarySystemBackground
            
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            navigationBarAppearance.backgroundColor = .tertiarySystemBackground
            // remove bottom border
            navigationBarAppearance.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(settingsSheetVM: SettingsSheetViewModel(), postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
    }
}
