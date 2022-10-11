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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // create 4 rounded ovals, with different border colors, that can be selected
                            // when selected, change the color of the oval to the color of the selected color
                            // the ovals should have the words "rant", "confession", "event", and "question" in them
                            
                            Spacer()
                                .frame(maxWidth: 10)
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "rant" {
                                    newPostVM.tag = "rant"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "rant" ? Color(UIColor.red) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.red), lineWidth: 2)
                                        )
                                    
                                    Text("Rant")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "rant" ? Color(UIColor.white) : Color(UIColor.red))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "confession" {
                                    newPostVM.tag = "confession"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "confession" ? Color(UIColor.yellow) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.yellow), lineWidth: 2)
                                        )
                                    
                                    Text("Confession")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "confession" ? Color(UIColor.white) : Color(UIColor.yellow))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "question" {
                                    newPostVM.tag = "question"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "question" ? Color(UIColor.blue) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.blue), lineWidth: 2)
                                        )
                                    
                                    Text("Question")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "question" ? Color(UIColor.white) : Color(UIColor.blue))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "event" {
                                    newPostVM.tag = "event"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "event" ? Color(UIColor.systemPink) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.systemPink), lineWidth: 2)
                                        )
                                    
                                    Text("Event")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "event" ? Color(UIColor.white) : Color(UIColor.systemPink))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "meme" {
                                    newPostVM.tag = "meme"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "meme" ? Color(UIColor.purple) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.purple), lineWidth: 2)
                                        )
                                    
                                    Text("Meme")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "meme" ? Color(UIColor.white) : Color(UIColor.purple))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "w" {
                                    newPostVM.tag = "w"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "w" ? Color(UIColor.blue) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.blue), lineWidth: 2)
                                        )
                                    
                                    Text("W")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "w" ? Color(UIColor.white) : Color(UIColor.blue))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "rip" {
                                    newPostVM.tag = "rip"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "rip" ? Color(UIColor.black) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.black), lineWidth: 2)
                                        )
                                    
                                    Text("RIP")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "rip" ? Color(UIColor.white) : Color(UIColor.black))
                                }
                            }
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if newPostVM.tag != "class" {
                                    newPostVM.tag = "class"
                                }
                                else {
                                    newPostVM.tag = nil
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(newPostVM.tag == "class" ? Color(UIColor.brown) : Color(UIColor.clear))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(UIColor.brown), lineWidth: 2)
                                        )
                                    
                                    Text("Class")
                                        .font(.system(size: 16))
                                        .foregroundColor(newPostVM.tag == "class" ? Color(UIColor.white) : Color(UIColor.brown))
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 25)
                    
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
