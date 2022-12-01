import SwiftUI
import AlertToast
import Resolver

struct WaitlistView: View {
    private let logoDim: CGFloat = 128
    @StateObject var emailVerificationVM = EmailVerificationViewModel()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Image("PongTextLogo")
                .padding(.bottom)
            
            Text("You're on the waitlist!")
                .font(.title)
                .fontWeight(.heavy)
            
            Text("The Pong community at your school isn’t open yet, but we’ll be there soon!")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.pongSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Spacer()
            
            Text("Want to help bring Pong to your school?")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(Color.pongSecondaryText)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                EmailController().sendEmail(subject: "[WAITLIST]")
            } label: {
                HStack(spacing: 3) {
                    Image("envelope")
                        .font(.subheadline)
                    
                    Text("Email Us")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .foregroundColor(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke().foregroundColor(Color.pongAccent))
                .background(Color.pongAccent)
                .cornerRadius(15)
            }
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 40)
        .padding(.horizontal, 20)
        .background(Color.pongSystemBackground)
        .statusBar(hidden: true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button() {
                    withAnimation {
                        DispatchQueue.main.async {
                            AuthManager.authManager.isSignedIn = false
                            AuthManager.authManager.waitlisted = false
                        }
                    }
                }
                label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.pongLabel)
                }
            }
        }
    }
}

