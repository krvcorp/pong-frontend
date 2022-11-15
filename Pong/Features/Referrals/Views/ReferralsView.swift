import SwiftUI
import Foundation
import UniformTypeIdentifiers
import AlertToast
import PartialSheet

struct ReferralsView: View {
    let progressFrame : CGFloat = CGFloat(UIScreen.screenWidth - 25)
    
    @StateObject var referralsVM = ReferralsViewModel()
    @ObservedObject var dataManager = DataManager.shared
    
    @State private var sheet : Bool = false
    @State private var halfSheetPresented : Bool = false
    
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
                    HStack {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            sheet.toggle()
                        } label: {
                            Text("Invite friends")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $sheet) {
                            let referralCode = DAKeychain.shared["referralCode"]!
                            let url = "This new app just came out for BU use my referral code \(referralCode) https://www.pong.college/refer/"
                            ShareSheet(items: [url])
                        }
                    }
                    .padding(15)
                    .foregroundColor(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                    .background(Color.pongAccent)
                    .cornerRadius(20)

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
                        })
                    
                    Spacer()
                    
                }
            }
            .padding(.bottom, 100)
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
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
        .toast(isPresenting: $dataManager.errorDetected) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
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
                        Text("$10")
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
                        Text("2")
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
                VStack {
                    HStack {
                        Spacer()
                        Text("11/12/22")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("Date joined")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "777777"))
                        Spacer()
                    }
                }
            }
            
            HStack {
                Text("$15 for 5 friends")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack {
                Text("Get 5 friends to join Pong this week and we'll send you $15.")
                    .font(.callout)
                Spacer()
            }
            
            HStack {
                Text("Invites can be sent until November 26th")
                    .font(.caption)
                    .italic()
                Spacer()
            }
            
            Rectangle()
                .fill(Color.pongSecondarySystemBackground)
                .frame(height: 10)
                .listRowBackground(Color.pongSecondarySystemBackground.edgesIgnoringSafeArea([.leading, .trailing]))
                .listRowSeparator(.hidden)
                .padding(0)
                .listRowInsets(EdgeInsets())
            
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.pongSecondarySystemBackground)
                        .frame(width: progressFrame)
                        .opacity(0.5)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "00D400"))
                        .frame(width: progressFrame * (0.2))
                }
                .padding(.top, 5)
                .frame(height: 15)
                
                if (6 > 5) {
                    HStack {
                        Image("send")
                            .font(.headline)
                    }
                    .padding(15)
                    .foregroundColor(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                    .background(Color.pongAccent)
                    .cornerRadius(20)
                }
            }
            
        }
    }
}
