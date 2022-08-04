//
//  MessagesView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct MessagesView: View {
    
    func standardizedParagraph(title: String, text: String, imageName: String?) -> some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(title)
                .font(.headline)
                .padding([.top], 6)
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .font(.subheadline)
                .padding([.top], 6)
                .fixedSize(horizontal: false, vertical: true)
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .cornerRadius(16)
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray, lineWidth: 3)
                            )
                    .padding([.top])
            }
        }
        .padding([.bottom])
    }
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            NavigationView {
                List {
                    NavigationLink(destination: Text("messaging feed here")) {
                        HStack {
                            LinearGradient(gradient: Gradient(colors: [Color.releaseNotesGradient1, Color.releaseNotesGradient2]), startPoint: .trailing, endPoint: .leading).clipShape(Circle()).frame(width: 40, height: 40, alignment: .center)
                            VStack (alignment: .leading, spacing: 5) {
                                Text("Brattle street when jefes moves in").bold().lineLimit(1)
                                HStack {
                                    Text("Why would you post that").lineLimit(1).foregroundColor(.gray)
                                    Spacer()
                                    ZStack {
                                        LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                        Text("4:34 PM").foregroundColor(.white).bold().lineLimit(1)
                                    }
                                    .cornerRadius(6)
                                    .frame(width: 75)
                                }
                            }
                        }.padding(.vertical, 10)
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    UITableView.appearance().backgroundColor = UIColor(Color(white: 0.0, opacity: 0.0))
                }
                .navigationTitle("Messages")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
