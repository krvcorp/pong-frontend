import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var authManager = AuthManager.authManager
    @StateObject var onboardingVM = OnboardingViewModel()
    @State private var selectedTab = 1
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.label
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    WelcomeView()
                        .tag(1)

                    InformationView()
                        .tag(2)
                    
                    RulesView()
                        .tag(3)
                    
                    ReferralOnboardingView()
                        .tag(4)
                }
                .onChange(of: selectedTab, perform: { newValue in
                    hideKeyboard()
                })
                .tabViewStyle(PageTabViewStyle())
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onboardingVM.onboard()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                }
                
                if selectedTab != 4 {
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
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.bottom)
                } else {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onboardingVM.onboard()
                    } label: {
                        Text("Continue")
                            .fontWeight(.medium)
                            .padding([.top, .bottom], 15)
                            .padding([.leading, .trailing], 90)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.bottom)
                }

            }
            .background(Color.pongSystemBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(onboardingVM)
    }
}

