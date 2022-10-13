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
    
    @State private var selectedFilter: Tags = .none
    @Namespace var animation
    
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
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $newPostVM.title)
                                .focused($textIsFocused)
                                .padding(4)
                            
                            if $newPostVM.title.wrappedValue == "" {
                                Text("What's on your mind?")
                                    .foregroundColor(Color.gray)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                            }
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
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.primary, lineWidth: 2))
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
    
    var TagBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollReader in
                HStack() {
                    ForEach(Tags.allCases, id: \.rawValue) { item in
                        if item != .none {
                            Text(item.title)
                                .padding()
                                .foregroundColor(Color(UIColor.label))
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.red), lineWidth: 2))
                                .background(item == selectedFilter ? Color(UIColor.red) : Color(UIColor.clear)) // If you have this
                                .cornerRadius(5)         // You also need the cornerRadius here
                                .padding(.bottom)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        self.selectedFilter = item
                                    }
                                }
                        }
                    }
                }
                .overlay(Divider().offset(x: 0, y: 16))
                .onChange(of: selectedFilter, perform: { value in
                    print("DEBUG: selectedFilter Changed")
                    print("DEBUG: \(value)")
                    withAnimation{
                        scrollReader.scrollTo(value.rawValue, anchor: .center)
                    }
                })
            }
        }
    }
}
