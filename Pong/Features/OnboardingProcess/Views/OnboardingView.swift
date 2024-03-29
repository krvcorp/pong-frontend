import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    @StateObject var onboardingVM = OnboardingViewModel()
    
    @State private var selectedTab = 1
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.pongAccent)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.label
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                WelcomeView()
                    .tag(1)

                RulesView()
                    .tag(2)
                
                ReferralOnboardingView()
                    .tag(3)
            }
            .onChange(of: selectedTab, perform: { newValue in
                hideKeyboard()
            })
            .tabViewStyle(PageTabViewStyle())
            
            if selectedTab != 3 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        selectedTab = selectedTab + 1
                    }
                } label: {
                    Text("Next")
                        .fontWeight(.medium)
                        .padding([.top, .bottom], 15)
                        .padding([.leading, .trailing], 90)
                        .background(Color.pongAccent)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.bottom)
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onboardingVM.onboard()
                } label: {
                    Text("Next")
                        .fontWeight(.medium)
                        .padding([.top, .bottom], 15)
                        .padding([.leading, .trailing], 90)
                        .background(Color.pongAccent)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.bottom)
            }

        }
        .ignoresSafeArea(.keyboard)
        .background(Color.pongSystemBackground)
        .environmentObject(onboardingVM)
    }
}

