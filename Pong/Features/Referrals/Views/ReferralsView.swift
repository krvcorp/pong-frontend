import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct ReferralsView: View {
    // MARK: ViewModels
    @StateObject var referralsVM = ReferralsViewModel()
    @State private var sheet : Bool = false
    
    var body: some View {
        List {
            Section() {
                HStack() {
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("\(referralsVM.numberReferred)")
                            .font(.title.bold())
                            .foregroundColor(.green)
                        Text("Referrals")
                    }
                    
                    Spacer()
                }
            }
            
            Section() {
                VStack {
                    Text("Want to win $100?")
                        .font(.title).bold()
                        .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Each referral is a chance to win!")
                                .font(.title3).bold()
                                .padding(.bottom)
                            
                            Text("Venmo, CashApp, Zelle, or Bitcoin - we don't discriminate.")
                                .font(.caption)
                            
                            Text("Promotion ends 9/30/22")
                                .font(.caption)
                        }
                        .padding()
                        
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.screenWidth / 4)
                            .padding()
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            
            Section(header: Text("Your Referral Code")) {
                HStack {
                    let referralCode = DAKeychain.shared["referralCode"]!
                    Text("\(referralCode)")
                        .font(.title.bold())
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        sheet.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $sheet) {
                        let referralCode = DAKeychain.shared["referralCode"]!
                        let url = URL(string: "https://www.pong.college/\(referralCode)")
                        ShareSheet(items: [url!])
                    }
                }
            }
            
            Section() {
                VStack {
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.screenWidth / 4)
                    
                    Text("Tap the share button to share the app link and your referral code and earn cash.")
                }
                .foregroundColor(.gray)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
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
