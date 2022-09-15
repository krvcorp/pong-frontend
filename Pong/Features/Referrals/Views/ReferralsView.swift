import SwiftUI
import Foundation

struct ReferralsView: View {
    // MARK: ViewModels
    @StateObject var referralsVM = ReferralsViewModel()
    @State private var sheet : Bool = false
    
    var body: some View {
        VStack{
            Rectangle()
                .fill(.blue)
                .overlay(
                    VStack {
                        Text("For each friend you refer to Pong, we'll Venmo you 5$.")
                            .font(.title).bold()
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        Text("(or CashApp, Zelle, Bitcoin - we don't discriminate.)")
                            .font(.caption)
                            .padding(.leading, 20)
                            .padding(.top, 2)
                            .padding(.bottom, 5)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: CGFloat(150))
            HStack {
                Text("You currently have \(referralsVM.getReferralsText())")
                    .font(.title.bold())
                    .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
            }
                
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                sheet.toggle()
            } label: {
//                Image(systemName: "square.and.arrow.up.circle")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: UIScreen.screenWidth / 7)
                Text("Share Pong")
            }
            .padding(.bottom, 5)
            .sheet(isPresented: $sheet) {
                let referralCode = DAKeychain.shared["referralCode"]!
                let url = URL(string: "https://www.pong.college/\(referralCode)")
                ShareSheet(items: [url!])
            }
            
        }
        .onAppear{
            referralsVM.getNumReferred()
        }
        .navigationBarTitle("Invite Friends")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReferralsView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralsView()
    }
}
