import SwiftUI
import AlertToast
import Resolver

struct EmailVerificationView: View {
    private let logoDim: CGFloat = 128
    @StateObject var emailVerificationVM = EmailVerificationViewModel()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Spacer()
            
            if colorScheme == .dark {
                Image("PongTextLogoDarkMode")
            } else {
                Image("PongTextLogoLightMode")
            }
            
            Text("Bounce your ideas")
                .font(.system(size: 20, weight: .medium))
            
            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                emailVerificationVM.signinWithGoogle()
            } label: {
                HStack {
                    Spacer()
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(8)
                    Text("Login with Google")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                        .padding([.leading], -6)
                    Spacer()
                }
                .background(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding([.leading, .trailing], 30)
                .shadow(color: Color(white: 0.1, opacity: 0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 16)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                emailVerificationVM.signInWithMicrosoft()
            } label: {
                HStack {
                    Spacer()
                    Image("MicrosoftLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(8)
                    Text("Login with Microsoft")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .background(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding([.leading, .trailing], 30)
                .shadow(color: Color(white: 0.1, opacity: 0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.pongSystemBackground)
        .statusBar(hidden: true)
        .toast(isPresenting: $emailVerificationVM.loginError) {
            AlertToast(type: .error(.red), title: emailVerificationVM.loginErrorMessage)
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
    }
}
