import SwiftUI

struct SettingsOptionRowView: View {
    let settingsSheetEnum: SettingsSheetEnum

    var body: some View {
        VStack {
            HStack(spacing: 16) {

                Image(systemName: settingsSheetEnum.imageName)
                    .foregroundColor(.gray)

                Text(settingsSheetEnum.title)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Divider()
        }
        .background(Color(UIColor.systemGroupedBackground)) // necessary for clickable background
    }
}

struct SettingsOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsOptionRowView(settingsSheetEnum: .preferences)
    }
}
