import SwiftUI

struct PostSettingsRowView: View {
    let viewModel: PostSettingsOptionsViewModel

    var body: some View {
        VStack {
            HStack(spacing: 16) {

                Image(systemName: viewModel.imageName)
                    .foregroundColor(.gray)

                Text(viewModel.title)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Divider()
        }
    }
}

struct PostSettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        PostSettingsRowView(viewModel: .save)
    }
}
