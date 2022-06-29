//
//  MessageBlockView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct MessageBlock: View {
    var body: some View {
        VStack{
            NavigationLink {
                ChatView()
            } label: {
                
                HStack{
                    Circle()
                        .fill(.blue)
                        .frame(width: 50, height: 50)
                    
                    VStack{
                        HStack(alignment: .top){
                            VStack(alignment: .leading){
                                HStack{
                                    Text("Anonymous")
                                        .font(.title3.bold())
                                        .padding(.bottom, 4)

                                    Spacer()
                                    
                                    Text("2:39 PM")
                                        .font(.caption)
                                }

                                HStack{
                                    Text("Obama shared an image")
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Text("4")
                                        .font(.caption.bold())
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .background(
                                            Circle()
                                                .fill(.blue)
                                                .frame(width: 25, height: 25))
                                }
                            }
                            
                            Spacer()
                           
                        }
                        .padding(.bottom)
                    }
                }
                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
                .font(.system(size: 18).bold())
                .padding()
                .foregroundColor(Color(UIColor.label))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.label), lineWidth: 5))
            }
            .background(Color(UIColor.systemBackground)) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here
        }
    }
}

struct MessageBlock_Previews: PreviewProvider {
    static var previews: some View {
        MessageBlock()
    }
}
