////
////  Post.swift
////  SidechatMockup
////
////  Created by Khoi Nguyen on 6/3/22.
////
//
//import SwiftUI
//
//struct ProfileCommentBubble: View {
//    @State var comment: Comment
//    @StateObject var profileCommentBubbleVM = ProfileCommentBubbleViewModel()
//    @ObservedObject var postSettingsVM : PostSettingsViewModel
//    // some local logic
//    @State var sheet = false
//    @State private var tapped = false
//    @State private var showScore = false
//    @State private var hasAppeared = false
//    
//    var body: some View {
//        // somehow this navigation link takes up space which makes the view as desired
//        
//        VStack {
//            VStack {
//                HStack(alignment: .top){
//                    VStack(alignment: .leading){
//                        
//                        Text("\(comment.timeSincePosted)")
//                            .font(.caption)
//                            .padding(.bottom, 4)
//          
//                        Text(comment.comment)
//                            .multilineTextAlignment(.leading)
//                    }
//                    
//                    Spacer()
//                    
//                    VStack {
//                        if !showScore {
////                            Button {
////                                postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: 1) { result in
////                                }
////                            } label: {
////                                Image(systemName: "arrow.up")
////                            }
//                            
//                            Button {
//                                print("DEBUG: Score check")
//                                withAnimation {
//                                    showScore.toggle()
//                                }
//
//                            } label: {
//                                Text("\(comment.score)")
//                            }
//                            
////                            Button {
////                                postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: 1) { result in
////                                }
////                            } label: {
////                                Image(systemName: "arrow.down")
////                            }
//                        } else {
//                            Button {
//                                print("DEBUG: Score check")
//                                withAnimation {
//                                    showScore.toggle()
//                                }
//
//                            } label: {
//                                VStack {
//                                    Text("\(comment.score)")
//                                        .foregroundColor(.green)
//                                    Text("\(comment.score)")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
//
//                    }
//                    .frame(width: 15, height: 50)
//                }
//                .padding(.bottom)
//
//                Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)
//                
//                // bottom row of contents
//                HStack {
//
//                    Image(systemName: "bubble.left")
//                    Text("Re: \(profileCommentBubbleVM.post.title)")
//                        .font(.subheadline).bold()
//                    
//
//                    Spacer()
//                    
////                    Button {
////                        sheet.toggle()
////
////                    } label: {
////                        Image(systemName: "square.and.arrow.up")
////                    }
////                    .sheet(isPresented: $sheet) {
////                        ShareSheet(items: ["\(post.title)"])
////                    }
//                    
//                    Button {
//                        profileCommentBubbleVM.deleteComment(comment_id: comment.id)
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                }
//            }
//        }
//        .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
//        .font(.system(size: 18).bold())
//        .padding()
//        .foregroundColor(Color(UIColor.label))
//        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.tertiarySystemBackground), lineWidth: 5))
//        .background(Color(UIColor.tertiarySystemBackground)) // If you have this
//        .cornerRadius(10)         // You also need the cornerRadius here
//        .onAppear {
//            if !hasAppeared {
//                print("DEBUG: onAppear")
//                profileCommentBubbleVM.readPost(postId: comment.post)
//                hasAppeared.toggle()
//            }
//        }
//        .padding(.top, 5)
//    }
//}
//
