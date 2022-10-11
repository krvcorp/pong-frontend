import SwiftUI
import Combine
import AlertToast

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager : DataManager
    @StateObject var newPostVM = NewPostViewModel()
    @ObservedObject var mainTabVM : MainTabViewModel
    
    @FocusState private var textIsFocused : Bool
    
    // MARK: image uploader
    @State private var showSheet = false

    // MARK: new poll
    @State private var showNewPoll = false
    
    var body: some View {
        ZStack {
            ZStack (alignment: .bottom) {
                VStack {
                    VStack {
                        HStack {
                            Button {
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.label))
                            }
                            .padding(.top)
                            .padding(.horizontal)

                            Spacer()
                        }

//                        let prompts = ["What's on your mind?", "What's upsetting you right now?", "Who do you hate?", "Seen anything interesting lately?", "How's your day going?"]
                        // MARK: TextArea
                        let prompts = ["What's on your mind?"]
                        
                        ZStack(alignment: .topLeading) {
                            if $newPostVM.title.wrappedValue == "" {
                                Text(prompts.randomElement()!)
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $newPostVM.title)
                                .focused($textIsFocused)
                                .padding(4)
                        }
                        .font(.title)
                        .frame(maxHeight: .infinity)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {  /// Anything over 0.5 seems to work
                                textIsFocused = true
                             }
                        }
                        
                        if newPostVM.image != nil {
                            ZStack(alignment: .topLeading) {

                                Image(uiImage: self.newPostVM.image!)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    newPostVM.image = nil
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black).opacity(0.6))
                                .padding()
                            }
                            .frame(maxWidth: UIScreen.screenWidth / 1.25)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding()
                        }
                        
                        if showNewPoll == true {
                            NewPoll(showNewPoll: $showNewPoll, newPollVM: newPostVM.newPollVM)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                // MARK: Image picker
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showSheet = true
                                    showNewPoll = false
                                    newPostVM.newPollVM.reset()
                                } label: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }
                                .sheet(isPresented: $showSheet) {
                                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newPostVM.image)
                                }
                                .padding(.trailing)

                                // MARK: Poll generator
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showNewPoll.toggle()
                                    newPostVM.image = nil
                                    newPostVM.newPollVM.reset()
                                    if showNewPoll {
                                        newPostVM.newPollVM.instantiate()
                                    }
                                } label: {
                                    Image(systemName: "chart.bar")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }

                                
                                Spacer()
                                Text("\(newPostVM.characterLimit - newPostVM.title.count)")
                                    .foregroundColor(newPostVM.characterLimit - newPostVM.title.count <= 30 ? .red : Color(UIColor.label))
                            }
                            .padding()
                            .frame(minHeight: 25, maxHeight: 60)

                            // MARK: On success of newPost, NewPostView needs to dismiss to reset data in NewPost
                            if !newPostVM.newPostLoading {
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    DispatchQueue.main.async {
                                        newPostVM.newPostLoading = true
                                    }
                                    newPostVM.newPost(mainTabVM: mainTabVM, dataManager: dataManager)
                                    NotificationsManager.notificationsManager.registerForNotifications()
                                } label: {
                                    Text("Post")
                                        .frame(minWidth: 100, maxWidth: 150)
                                        .font(.system(size: 18).bold())
                                        .padding()
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.primary, lineWidth: 2)
                                    )
                                }
                                .background(Color(UIColor.label)) // If you have this
                                .cornerRadius(20)         // You also need the cornerRadius here
                                .padding(.bottom)
                            } else {
                                Button {
                                    
                                } label: {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                        .frame(minWidth: 100, maxWidth: 150)
                                        .font(.system(size: 18).bold())
                                        .padding()
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.primary, lineWidth: 2)
                                        )
                                }
                                .background(Color(UIColor.label)) // If you have this
                                .cornerRadius(20)         // You also need the cornerRadius here
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $newPostVM.error) {
            AlertToast(type: .error(.red), title: newPostVM.errorMessage)
        }
    }
}
