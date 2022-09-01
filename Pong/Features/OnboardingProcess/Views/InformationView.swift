//
//  InformationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/31/22.
//

import SwiftUI

struct InformationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Self-expression")
                .font(.title.bold())
            
            Text("Anonymity helps us express ourselves in honest ways.")
                .font(.title3)
            
            Text("Hot takes, memes, confessions. We really don't care.")
                .font(.title3)
            
            Spacer()
        }
        .padding()
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
