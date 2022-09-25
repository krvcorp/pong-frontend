import SwiftUI
import AlertToast
import Resolver

struct EmailVerificationView: View {
    private let logoDim: CGFloat = 128
    @StateObject var emailVerificationVM = EmailVerificationViewModel()
    @StateObject var msalModel: MSALScreenViewModel = MSALScreenViewModel()
//    @EnvironmentObject var msAuthState: MSAuthState

//    private let msAuthAdapter: MSAuthAdapterProtocol = resolve()
    
    var body: some View {
        VStack {
            Image("pong_transparent_logo")
                .resizable()
                .frame(width: logoDim, height: logoDim)
                .shadow(color: Color(white: 0.05, opacity: 0.7), radius: 12, x: 0, y: 6)
                .padding(.top, 32)
            Text("Pong")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, -4)
            Text("Bounce your ideas")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(white: 0.7, opacity: 1))
            Spacer(minLength: 36)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                emailVerificationVM.signinWithGoogle()
            } label: {
                HStack {
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(8)
                    Text("College Email")
                        .fontWeight(.semibold)
                        .foregroundColor(.poshDarkPurple)
                        .padding([.leading], -6)
                    Spacer()
                }
                .background(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding([.leading, .trailing], 44)
                .shadow(color: Color(white: 0.1, opacity: 0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 32)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                emailVerificationVM.signInWithMicrosoft()
//                msAuthAdapter.login(withInteraction: true)
//                msalModel.loadMSALScreen()
            } label: {
                HStack {
                    Image("GoogleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .padding(8)
                    Text("Microsoft Email")
                        .fontWeight(.semibold)
                        .foregroundColor(.poshDarkPurple)
                        .padding([.leading], -6)
                    Spacer()
                }
                .background(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding([.leading, .trailing], 44)
                .shadow(color: Color(white: 0.1, opacity: 0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 32)
            
            MSALScreenView_UI(viewModel: msalModel)
                .frame(width: 250, height: 250, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            LinearGradient(stops: [
                .init(color: .richIndigoRedTint.indigoRedArray[1], location: 0),
                .init(color: .richIndigoRedTint.indigoRedArray[2], location: 0.2),
                .init(color: .richIndigoRedTint.indigoRedArray[6], location: 0.75),
                .init(color: .richIndigoRedTint.indigoRedArray[10], location: 1)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
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
