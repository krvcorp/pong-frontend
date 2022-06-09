//
//  FeedView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct FeedView: View {
    @State private var selectedFilter: FeedFilterViewModel = .hot
    @StateObject var api = API()
    @Namespace var animation
    
    var body: some View {
        VStack {
            
            feedFilterBar
                .padding(.top)
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack {
                        ForEach(api.posts) { post in
                            PostBubble(post: post, expanded: false)
                        }
                    }
                    .onAppear {
                        api.getPosts()
                    }
                }
                
                NavigationLink {
                    NewPostView()
                } label: {
                    Text("New Post")
                        .frame(minWidth: 100, maxWidth: 150)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white, lineWidth: 2)
                    )
                }
                .background(Color.black) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
                .padding(.bottom)
            }
        }
    }
    
    var feedHeader: some View {
        ZStack{
            Text("Harvard")
                .font(.title.bold())
            
            HStack(alignment: .center) {
                
                Spacer()
                
                Button {
                    print("DEBUG: Leaderboard")
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
                .padding()
            }
        }
    }
    
    var feedFilterBar: some View {
        HStack {
            ForEach(FeedFilterViewModel.allCases, id: \.rawValue) { item in
                VStack {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == item ? .semibold : .regular)
                        .foregroundColor(selectedFilter == item ? .black : .gray)
                    
                    if selectedFilter == item {
                        Capsule()
                            .foregroundColor(Color(.systemBlue))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "filter", in: animation)
                        
                    } else {
                        Capsule()
                            .foregroundColor(Color(.clear))
                            .frame(height: 3)
                    }
                    
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.selectedFilter = item
                    }
                }
            }
        }
        .overlay(Divider().offset(x: 0, y: 16))
    }
    
}



struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
