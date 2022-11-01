import SwiftUI
import Foundation
import UniformTypeIdentifiers
import AlertToast

struct ReferralsView: View {
    @StateObject var referralsVM = ReferralsViewModel()
    @ObservedObject var dataManager = DataManager.shared
    @State private var sheet : Bool = false
    
    @State var referralCode: String = ""
    
    // MARK: Body
    var body: some View {
        List {
            // MARK: Title
            VStack(spacing: 15) {
                HStack {
                    Text("Refer a friend")
                        .font(.title2)
                        .fontWeight(.heavy)
                    Spacer()
                }
                
                HStack {
                    Text("And you can make $15")
                        .font(.headline)
                    Spacer()
                }

            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            // MARK: ReferralPageImage
            HStack {
                Spacer()
                Image("ReferralPageImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.screenWidth / 2)
                Spacer()
            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)

            
            // MARK: Instructions
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                
                Text("How it works")
                
                Spacer()
            }
            .font(.headline.bold())
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            // MARK: VStack of steps
            VStack(spacing: 15) {
                instructionComponent(number: "1", title: "Invite your friends", subTitle: "Just share your link")
                instructionComponent(number: "2", title: "They download the app", subTitle: "Share funny content")
                instructionComponent(number: "3", title: "You make $$$", subTitle: "5 referrals for $15!")
            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            
            // MARK: Copy Code + Share App Link
            VStack {
                
                // MARK: Referral Code
                HStack {
                    HStack {
                        let referralCode = DAKeychain.shared["referralCode"]!
                        Text("www.pong.college/refer/\(referralCode)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            sheet.toggle()
                        } label: {
                            Text("share")
                                .font(.subheadline)
                                .fontWeight(.heavy)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $sheet) {
                            let referralCode = DAKeychain.shared["referralCode"]!
                            let url = URL(string: "https://www.pong.college/refer/\(referralCode)")
                            ShareSheet(items: [url!])
                        }
                    }
                    .padding(15)
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                
                // MARK: Enter Referral Code
                if !referralsVM.referred {
                    HStack {
                        HStack {
                            TextField("Enter Code", text: $referralCode)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if referralCode == "" {
                                Button(action: {
                                    referralsVM.setReferrer(referralCode: referralCode, dataManager: dataManager)
                                }) {
                                    Text("enter")
                                        .foregroundColor(Color(UIColor.quaternaryLabel))
                                        .font(.subheadline)
                                        .fontWeight(.heavy)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(true)
                            } else {
                                Button(action: {
                                    referralsVM.setReferrer(referralCode: referralCode, dataManager: dataManager)
                                }) {
                                    Text("enter")
                                        .font(.subheadline)
                                        .fontWeight(.heavy)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(15)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
                // MARK: Already been referred
                else {
                    HStack {
                        HStack {
                            Text(referralCode == "" ? "you've been referred!" : referralCode)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                referralsVM.setReferrer(referralCode: referralCode, dataManager: dataManager)
                            }) {
                                Text("enter")
                                    .foregroundColor(Color(UIColor.quaternaryLabel))
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(true)
                        }
                        .padding(15)
                    }
                    .background(Color(UIColor.systemGreen))
                    .cornerRadius(10)
                }
            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .listStyle(PlainListStyle())
        .onAppear{
            referralsVM.getNumReferred()
        }
        .navigationBarTitle("Referrals")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $dataManager.errorDetected) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
        }
    }
    
    // MARK: InstructionComponent
    @ViewBuilder
    func instructionComponent(number: String, title : String, subTitle: String) -> some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                
                Text("\(number)")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(number != "3" ? Color(UIColor.label) : Color(UIColor.systemGreen))
            }
            .frame(width: 50, height: 50)
            .shadow(color: Color(UIColor.lightGray).opacity(0.5), radius: 5, x: 0, y: 0)
            
            VStack(spacing: 5) {
                HStack {
                    Text("\(title)")
                        .font(.subheadline.bold())
                    Spacer()
                }
                
                HStack {
                    Text("\(subTitle)")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
}

struct ReferralsView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralsView()
    }
}
