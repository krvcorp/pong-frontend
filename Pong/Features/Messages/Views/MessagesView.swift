import SwiftUI

struct MessagesView: View {
    
    @State private var searchText = ""
    @State private var showAlert = false
    
    struct ChatModel: Identifiable {
        var id: String { title }
        let title: String
        let subtitle: String
        let timestamp: String
        let new: Bool
        let color1: Color
        let color2: Color
    }
    
    let chatmodels: [ChatModel] = [ChatModel(title: "Brattle street when jefes moves in", subtitle: "Why would you post that", timestamp: "6:09 PM", new: true, color1: Color.releaseNotesGradient1, color2: Color.releaseNotesGradient2), ChatModel(title: "I am getting housing at adams, but I'm also secretly", subtitle: "How much for the appt", timestamp: "4:20 PM", new: true, color1: Color.analyticsRevenueGradient1, color2: Color.analyticsRevenueGradient2), ChatModel(title: "Winthrop dining hall vibes are fire", subtitle: "No they're not", timestamp: "3:07 PM", new: false, color1: Color.webListItemGradient1, color2: Color.blue), ChatModel(title: "What if I 👉👈 got the HSA bigger bed", subtitle: "What if you didn't", timestamp: "2:59 PM", new: false, color1: Color.trackingLinksGradient1, color2: Color.trackingLinksGradient2), ChatModel(title: "is 1011a THAT hard...", subtitle: "Yes", timestamp: "1:06 PM", new: false, color1: Color.guestListGradient1, color2: Color.guestListGradient2)]
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            List {
                Section(header: Text("Messages")) {
                    ForEach(chatmodels.filter { searchText.isEmpty || $0.title.localizedStandardContains(searchText)}) { chatmodel in
                        NavigationLink(destination: Text("messaging feed here")) {
                            HStack {
                                LinearGradient(gradient: Gradient(colors: [chatmodel.color1, chatmodel.color2]), startPoint: .bottomLeading, endPoint: .topTrailing).clipShape(Circle()).frame(width: 40, height: 40, alignment: .center)
                                    .padding(.trailing, 4)
                                VStack (alignment: .leading, spacing: 6) {
                                    Text(chatmodel.title).bold().lineLimit(1)
                                    HStack {
                                        Text(chatmodel.subtitle).lineLimit(1).foregroundColor(.gray)
                                        Spacer()
                                        ZStack {
                                            if chatmodel.new {
                                                LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                            } else {
                                                Color(UIColor.secondarySystemFill)
                                            }
                                            Text(chatmodel.timestamp).foregroundColor(chatmodel.new ? .white : .gray).bold().lineLimit(1)
                                        }
                                        .cornerRadius(6)
                                        .frame(width: 75)
                                    }
                                }
                            }.padding(.vertical, 10)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                UITableView.appearance().showsVerticalScrollIndicator = false
            }
            .navigationTitle("Messages")
//            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
        }
    }
    
    func dontEnableNotifs() {
        
    }
    
    func enableNotifs() {
        
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
