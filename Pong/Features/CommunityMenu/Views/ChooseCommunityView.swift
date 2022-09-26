//
//  ChooseCommunityView.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/29/22.
//

import SwiftUI

struct ChooseCommunityView: View {
    //    var body: some View {
    //        VStack(alignment: .leading) {
    //            Text("Check out these communities!")
    //                .bold()
    //                .padding(.top)
    //                .padding(.horizontal)
    //
    //            List {
    //                Text("All colleges!")
    //                Text("Boston University")
    //            }
    //            .refreshable {
    //                print("DEBUG: Community Refresh")
    //            }
    //            .background(Color(UIColor.secondarySystemBackground))
    //        }
    //        .background(Color(UIColor.secondarySystemBackground))
    //        .frame(maxWidth: .infinity, alignment: .leading)
    //    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Visit other communities!")
                .bold()
                .padding(.top)
                .padding(.horizontal)
            
            List {
                Text("All")
                Text("Knowledge Base")
                Text("Boston University")
                Text("Lesley University")
            }
            .refreshable {
                print("DEBUG: Community Refresh")
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .background(Color(UIColor.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct ChooseCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseCommunityView()
    }
}
