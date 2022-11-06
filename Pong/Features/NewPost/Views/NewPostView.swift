import SwiftUI
import Combine
import AlertToast

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager : DataManager
    @StateObject var newPostVM = NewPostViewModel()
    @ObservedObject var mainTabVM : MainTabViewModel
    @FocusState private var textIsFocused : Bool
    @State private var showSheet = false
    @State private var showNewPoll = false
    
    @Namespace var animation
    
    // MARK: Body
    var body: some View {
        NavigationView {
            ZStack (alignment: .bottom) {
                VStack {
                    VStack {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $newPostVM.title)
                                .background(Color.pongSystemBackground)
                                .focused($textIsFocused)
                                .padding(4)
                                .onAppear() {
                                    UITextView.appearance().backgroundColor = .clear
                                }
                            
                            if $newPostVM.title.wrappedValue == "" {
                                Text("What's on your mind?")
                                    .foregroundColor(Color.pongSecondaryText)
                                    .background(Color.pongSystemBackground)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                            }
                        }
                        .background(Color.pongSystemBackground)
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
                    .background(Color.pongSystemBackground)
                    
                    Spacer()
                    
                    TagBar
                    
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
                                    Image("gallery-add")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color.pongAccent)
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
                                    Image("poll")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color.pongAccent)
                                }
                                
                                Spacer()
                                Text("\(newPostVM.characterLimit - newPostVM.title.count)")
                                    .foregroundColor(newPostVM.characterLimit - newPostVM.title.count <= 30 ? .red : Color(UIColor.label))
                            }
                            .padding()
                            .frame(minHeight: 25, maxHeight: 65)
                        }
                    }
                }
                .background(Color.pongSystemBackground)
            }
            .navigationBarTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // MARK: On success of newPost, NewPostView needs to dismiss to reset data in NewPost
                    if !newPostVM.newPostLoading {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.async {
                                newPostVM.newPostLoading = true
                            }
                            newPostVM.newPost(mainTabVM: mainTabVM, dataManager: dataManager)
                            NotificationsManager.shared.registerForNotifications(forceRegister: false)
                        } label: {
                            Text("Post")
                                .bold()
                                .foregroundColor(Color.pongAccent)
                        }
                    } else {
                        Button {
                            print("DEBUG: NewPostIsLoading")
                        } label: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                .foregroundColor(Color.pongAccent)
                        }
                        .disabled(true)
                    }
                }
            }
        }
        .toast(isPresenting: $newPostVM.error) {
            AlertToast(type: .error(.red), title: newPostVM.errorMessage)
        }
        .accentColor(Color.pongAccent)
    }
    
    // MARK: TagBar
    var TagBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollReader in
                HStack {
                    ForEach(Tag.allCases, id: \.rawValue) { item in
                        if item != .none {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(item == newPostVM.selectedTag ? item.color : Color.pongSystemBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(item.color, lineWidth: 1)
                                    )
                                    .padding(.vertical, 2)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            if self.newPostVM.selectedTag == item {
                                                self.newPostVM.selectedTag = .none
                                            } else {
                                                self.newPostVM.selectedTag = item
                                            }
                                        }
                                    }
                                
                                Text(item.title!)
                                    .bold()
                                    .padding(5)
                                    .padding(.horizontal, 5)
                                    .foregroundColor(item == newPostVM.selectedTag ? Color.pongSystemBackground : item.color)
                            }
                            .frame(height: 35)
                            .frame(minWidth: UIScreen.screenWidth / 8)
                        }
                    }
                }
                .onChange(of: newPostVM.selectedTag, perform: { value in
                    withAnimation{
                        if value != .none {
                            scrollReader.scrollTo(value.rawValue, anchor: .center)
                        }
                    }
                })
                .padding(.horizontal)
            }
        }
    }
}
