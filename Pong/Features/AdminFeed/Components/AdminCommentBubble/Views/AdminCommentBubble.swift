//
//  AdminCommentBubble.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI
import AlertToast

struct AdminCommentBubble: View {
    @Binding var comment : Comment
    @EnvironmentObject var adminFeedVM: AdminFeedViewModel
    @StateObject var adminCommentBubbleVM = AdminCommentBubbleViewModel()

    struct AlertIdentifier: Identifiable {
        enum Choice {
            case timeoutDay, timeoutWeek, unflag
        }
        
        var id: Choice
    }
    
    @State private var alertIdentifier: AlertIdentifier?
    
    var body: some View {
        VStack {
            Text("\(comment.comment)")
            
            // MARK: Delete or More Button
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        adminCommentBubbleVM.comment = adminCommentBubbleVM.comment
                        self.alertIdentifier = AlertIdentifier(id: .timeoutDay)
                    }
                }
                label: {
                    Label("Apply 1 Day Timeout", systemImage: "exclamationmark.square")
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        adminCommentBubbleVM.comment = adminCommentBubbleVM.comment
                        self.alertIdentifier = AlertIdentifier(id: .timeoutWeek)
                    }
                } label: {
                    Label("Apply 1 Week Timeout", systemImage: "exclamationmark.square")
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        adminCommentBubbleVM.comment = adminCommentBubbleVM.comment
                        self.alertIdentifier = AlertIdentifier(id: .unflag)
                    }
                } label: {
                    Label("Unflag Post", systemImage: "flag.slash")
                }
                
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 30, height: 30)
            }
            .frame(width: 25, height: 25)
        }
        .onAppear {
            adminCommentBubbleVM.comment = self.comment
        }
        .onChange(of: adminCommentBubbleVM.comment) {
            self.comment = $0
        }
        // MARK: Timeout Confirmation
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .timeoutDay:
                return customAlert (
                    title: "Apply timeout",
                    message: "Are you sure you want to apply a 1 day timeout to \(adminCommentBubbleVM.comment.comment)",
                    secondaryButtonText: "Apply",
                    secondaryButtonAction: {
                        adminCommentBubbleVM.applyTimeout(adminFeedVM: adminFeedVM, time: 60 * 24)
                    }
                )
            case .timeoutWeek:
                return customAlert (
                    title: "Apply timeout",
                    message: "Are you sure you want to apply a 1 week timeout to \(adminCommentBubbleVM.comment.comment)",
                    secondaryButtonText: "Apply",
                    secondaryButtonAction: {
                        adminCommentBubbleVM.applyTimeout(adminFeedVM: adminFeedVM, time: 60 * 24 * 7)
                    }
                )
            case .unflag:
                return customAlert (
                    title: "Unflag post",
                    message: "Are you sure you want to unflag \(adminCommentBubbleVM.comment.comment)",
                    secondaryButtonText: "Unflag",
                    secondaryButtonAction: {
                        adminCommentBubbleVM.unflagComment(adminFeedVM: adminFeedVM)
                    }
                )
            }
        }
    }
    
    func customAlert(title: String, message: String, secondaryButtonText: String, secondaryButtonAction: @escaping () -> Void) -> Alert {
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(
                Text("Cancel")
            ),
            secondaryButton: .destructive(Text(secondaryButtonText)) {
                secondaryButtonAction()
            }
        )
    }
}
