import SwiftUI
import Foundation
import UniformTypeIdentifiers
import AlertToast
import PartialSheet

struct ReferralsView: View {
    @StateObject var referralsVM = ReferralsViewModel()
    @StateObject var dataManager = DataManager.shared
    
    @State private var sheet : Bool = false
    @State private var halfSheetPresented : Bool = false
    let progressFrame : CGFloat = CGFloat(UIScreen.screenWidth - 25)
    
    // MARK: Body
    var body: some View {
        List {
            // MARK: Title
            VStack(spacing: 15) {
                HStack {
                    Text("Get a $15 reward when you invite 5 friends!")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack {
                    Text("Get 5 friends to join by November 26th and we’ll send you 15$ as a thank you. Pong is a community, and we couldn’t do it without you.")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        sheet.toggle()
                    } label: {
                        Image("share")
                            .padding(15)
                            .foregroundColor(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                            .background(Color.pongAccent)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $sheet) {
                        let referralCode = DAKeychain.shared["referralCode"]!
                        let url = "https://pong.college/refer/ This new app just came out for BU use my referral code \(referralCode)"
                        ShareSheet(items: [url])
                    }

                    
                    
                    HStack {
                        Text("Invite Friends")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .padding(15)
                    .foregroundColor(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                    .background(Color.pongAccent)
                    .cornerRadius(20)
                    .background(NavigationLink("", destination: ReferralsInviteFriendsView()).opacity(0))
                    
                    

                    PSButton(
                        isPresenting: $halfSheetPresented,
                        label: {
                            HStack {
                                Text("Referral history")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .padding(15)
                            .foregroundColor(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                            .background(Color.pongAccent)
                            .cornerRadius(20)
                            .buttonStyle(PlainButtonStyle())
                        })
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                }
            }
            .padding(.bottom, 100)
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            .buttonStyle(PlainButtonStyle())
            
            // MARK: ReferralPageImage
            HStack {
                Spacer()
                Image("ReferralPageImage")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .partialSheet(isPresented: $halfSheetPresented, content: {
            ReferralSheet
        })
        .listStyle(PlainListStyle())
        .onAppear{
            referralsVM.getNumReferred()
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            referralsVM.getNumReferred()
        }
    }
    
    // MARK: ReferralSheet
    var ReferralSheet : some View {
        VStack {
            HStack {
                Spacer()
                Text("Referral history")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack {
                VStack {
                    HStack {
                        Spacer()
                        Text("$\((dataManager.numberReferred > 5 ? 5 : dataManager.numberReferred) * 3)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("Total earned")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "777777"))
                        Spacer()
                    }
                }
                VStack {
                    HStack {
                        Spacer()
                        Text("\(dataManager.numberReferred)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("Completed")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "777777"))
                        Spacer()
                    }
                }
            }
            .padding(.bottom)
            
            Rectangle()
                .fill(Color.pongSecondarySystemBackground)
                .frame(width: UIScreen.screenWidth, height: 10)
                .listRowBackground(Color.pongSecondarySystemBackground.edgesIgnoringSafeArea([.leading, .trailing]))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.bottom)
            
            VStack {
                HStack {
                    Text("$15 for 5 friends")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    
                    if (dataManager.numberReferred > 4) {
                        Button {
                            EmailController().sendEmailReferral()
                        } label: {
                            HStack {
                                Image("envelope")
                            }
                            .foregroundColor(Color.white)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                            .background(Color.pongAccent)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.bottom)
                
                HStack {
                    Text("Get 5 friends to join Pong this week and we'll send you $15.")
                        .font(.system(size: 14))
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("Invites can be sent until November 26th")
                        .font(.caption)
                        .italic()
                    Spacer()
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
            
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.pongSecondarySystemBackground)
                        .frame(width: progressFrame)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green)
                        .frame(width: progressFrame * (0.2) * CGFloat(dataManager.numberReferred > 5 ? 5 : dataManager.numberReferred))
                }
                .padding(.top, 5)
                .frame(height: 15)
            }
        }
    }
}
