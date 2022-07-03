//
//  PostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = PostViewModel()
    @StateObject var componentViewModel = ComponentsViewModel()
    @State private var message = ""
    @State var sheet = false
    
    var post: Post
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                mainPost
                LazyVStack {
                    ForEach(post.comments) { comment in
                        CommentBubble(comment: comment)
                    }
                }
            }
           
            HStack {
                CustomTextField(placeholder: Text("Enter your message here"), text: $message)
                
                Button {
                    print("DEBUG: Message sent")
                    message = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(10)
                        .background(.indigo)
                        .cornerRadius(50)
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemBackground), lineWidth: 2))
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }
    
    // unused component
    var postHeader: some View {
        ZStack{
            HStack(alignment: .center) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                }
                .padding()
                Spacer()
            }
        }
    }
    
    var mainPost: some View {
        ScrollView {
            LazyVStack{
                Button(action: {
                    print("DEBUG: Reply")
                }) {
                    VStack{
                        
                        HStack(alignment: .top){
                            VStack(alignment: .leading){
                                
                                Text("Anonymous ~ \(post.created_at)")
                                    .font(.caption)
                                    .padding(.bottom, 4)

                                                       
                                Text(post.title)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            
                            Spacer()
                            
                            VStack{
                                Button {
                                    componentViewModel.createPostVote(postid: post.id, direction: "up")
                                } label: {
                                    Image(systemName: "arrow.up")
                                }
                                Text("\(post.total_score)")
                                Button {
                                    componentViewModel.createPostVote(postid: post.id, direction: "down")
                                } label: {
                                    Image(systemName: "arrow.down")
                                }

                            }
                            
                        }
                        .padding(.bottom)
                        

                        //
                        HStack {
                            // comments, share, mail, flag

                            Spacer()
                            
                            Button {
//                                let image = self.mainPost.snapshot()
//                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                sheet.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .sheet(isPresented: $sheet) {
                                ShareSheet(items: ["\(post.title)"])
                            }
                            Button {
                                print("DEBUG: DM")
                            } label: {
                                Image(systemName: "envelope")
                            }
                            Button {
                                print("DEBUG: Report")
                            } label: {
                                Image(systemName: "flag")
                            }
                        }
                    }
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                }
                .background(Color(UIColor.systemBackground)) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
                ZStack {
                    Divider()
                    Text("\(post.num_comments) Comments")
                        .font(.caption)
                        .background(Rectangle().fill(Color(UIColor.systemBackground)).frame(minWidth: 90))
                        
                }

            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: default_post)
    }
}
