import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct ReferralsView: View {
    // MARK: ViewModels
    @StateObject var referralsVM = ReferralsViewModel()
    @State private var sheet : Bool = false
    
    var body: some View {
//        VStack{
//            Rectangle()
//                .fill(.blue)
//                .overlay(
//                    VStack {
//                        Text("For each friend you refer to Pong, we'll Venmo you 5$.")
//                            .font(.title).bold()
//                            .padding(.top, 20)
//                            .padding(.leading, 20)
//                        Text("(or CashApp, Zelle, Bitcoin - we don't discriminate.)")
//                            .font(.caption)
//                            .padding(.leading, 20)
//                            .padding(.top, 2)
//                            .padding(.bottom, 5)
//                    }
//                )
//                .frame(maxWidth: .infinity, maxHeight: CGFloat(150))
//            Spacer()
//            VStack {
//                HStack {
//                    Text("You have")
//                        .font(.title2)
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                }
//                HStack {
//                    Text("\(referralsVM.numberReferred)")
//                        .font(.system(size: 80))
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                }
//                HStack {
//                    Text("referrals. \(referralsVM.getReferralsText())")
//                        .font(.title2)
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                }
//            }
//            Spacer()
//
//
//            Button {
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                sheet.toggle()
//            } label: {
//                Text("Refer your friends")
//                    .frame(minWidth: 0, maxWidth: .infinity)
//                    .font(.system(size: 18))
//                    .padding()
//                    .foregroundColor(.white)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 25)
//                            .stroke(Color(UIColor.systemBlue), lineWidth: 2)
//                    )
//                    .background(Color(UIColor.systemBlue))
//                    .cornerRadius(25)
//            }
//            .padding(.bottom, 5)
//            .sheet(isPresented: $sheet) {
//                let referralCode = DAKeychain.shared["referralCode"]!
//                let url = URL(string: "https://www.pong.college/\(referralCode)")
//                ShareSheet(items: [url!])
//            }
//
//        }
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
                    
                    VStack(alignment: .center) {
                        Text("$\(referralsVM.numberReferred * 5).00")
                            .font(.title.bold())
                            .foregroundColor(.green)
                        Text("Earned")
                    }
                    Spacer()
                }
            }
            
            Section() {
                HStack {
                    VStack(alignment: .leading) {
                        Text("For each friend you refer to Pong, we'll Venmo you 5$.")
                            .font(.title3).bold()
                            .padding(.bottom)
                        
                        Text("(or CashApp, Zelle, Bitcoin - we don't discriminate.)")
                            .font(.caption)
                    }
                    .padding()
                    
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.screenWidth / 4)
                        .padding()
                }
                .listRowInsets(EdgeInsets())
            }
            
            Section() {
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
                    
                    Text("No invites yet! Tap the share button to share the app link and your referral code and earn cash.")
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
