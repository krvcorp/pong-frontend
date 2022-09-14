import SwiftUI
import Foundation

struct ReferralsView: View {
    // MARK: ViewModels
    @StateObject var referralsVM = ReferralsViewModel()
    @State private var sheet : Bool = false
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 20) {
                Text("Invite your friends!")
                    .font(.title).bold()
                
                Text("Pong is growing fast, but we need your help to spread even faster.")
                    .font(.title2).bold()
                
                Text("For each friend you refer, we'll send you 5 bucks.")
                
                HStack {
                    Spacer()
                    
                    Text("\(referralsVM.numberReferred)")
                        .font(.title.bold())
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    Text("referrals")
                        .font(.title.bold())
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                sheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth / 3)
            }
            .sheet(isPresented: $sheet) {
                let url = URL(string: "https://www.pong.college/\(String(describing: DAKeychain.shared["referralCode"]))")
                ShareSheet(items: [url!])
            }
            
        }
        .onAppear{
            referralsVM.getNumReferred()
        }
        .navigationBarTitle("Referrals")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

struct ReferralsView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralsView()
    }
}
