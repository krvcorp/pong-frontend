import SwiftUI
import Foundation
import Contacts
import UIKit

struct ReferralsInviteFriendsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @StateObject var contactsVM = ContactsViewModel()
    @State var contactsLoading : Bool = true
    @State private var searchText = ""
    @State private var sheet : Bool = false
    
    // MARK: Body
    var body: some View {
        List {
            VStack {
                HStack {
                    Text("Invite friends")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("When your friend joins Pong, we’ll let you know on the previous page.")
                        .font(.headline)
                        .fontWeight(.regular)
                    Spacer()
                }
            }
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            searchBar
                .listRowSeparator(.hidden)
                .listRowBackground(Color.pongSystemBackground)
            
            CustomListDivider()
            
            // , id: \.id) { $contact in

            if contactsLoading {
                HStack {
                    Spacer()
                    Text("Please enable contact permissions in settings.")
                        .listRowSeparator(.hidden)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                
                HStack {
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } label: {
                        Text("Settings")
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .foregroundColor(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke().foregroundColor(Color.pongAccent))
                            .background(Color.pongAccent)
                            .cornerRadius(15)
                            .listRowSeparator(.hidden)
                        
                    }
                    .listRowSeparator(.hidden)
                    
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    // filter out contacts that don't appear in searchText
                    ForEach($contactsVM.contacts, id: \.id) {
                        $contact in
                        if (contact.phone != nil) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(contact.firstName) \(contact.lastName)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("\(format(with: "(XXX) XXX-XXXX", phone: "\(contact.getLastTenDigits())"))")
                                        .font(.footnote)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Button {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            contact.sheetToggled.toggle()
                                        } label: {
                                            Text("Invite")
                                                .font(.headline)
                                                .fontWeight(.medium)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .sheet(isPresented: $contact.sheetToggled) {
                                            let referralCode = DAKeychain.shared["referralCode"]!
                                            let url = "https://www.pong.college/refer/ This new app just came out for BU use my referral code \(referralCode)"
                                            MessageComposeSheet(recipients: [contact.phone!], body: url) { messageSent in
                                                print("MessageComposeView with message sent? \(messageSent)")
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 25)
                                    .foregroundColor(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke().foregroundColor(Color.pongAccent))
                                    .background(Color.pongAccent)
                                    .cornerRadius(20)
                                    
                                    Spacer()
                                }
                                
                            }
                            .listRowBackground(Color.pongSystemBackground)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            
            
        }
        .scrollContentBackgroundCompat()
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color.pongSystemBackground)
        .listStyle(PlainListStyle())
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            contactsVM.getContacts() {
                success in
                contactsLoading = false
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "B3B3B3"))
            TextField("Search", text: $searchText)
                .font(Font.system(size: 16))
        }
        .padding(7)
        .background(Color.pongSearchBar)
        .cornerRadius(10)
    }
}

func format(with mask: String, phone: String) -> String {
    let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    var result = ""
    var index = numbers.startIndex // numbers iterator

    // iterate over the mask characters until the iterator of numbers ends
    for ch in mask where index < numbers.endIndex {
        if ch == "X" {
            // mask requires a number in this place, so take the next one
            result.append(numbers[index])

            // move numbers iterator to the next index
            index = numbers.index(after: index)

        } else {
            result.append(ch) // just append a mask character
        }
    }
    return result
}
