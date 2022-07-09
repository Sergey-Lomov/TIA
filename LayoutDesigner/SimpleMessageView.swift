//
//  SimpleMessageView.swift
//  LayoutDesigner
//
//  Created by serhii.lomov on 05.07.2022.
//

import SwiftUI

struct SimpleMessageView: View {
    var message: String

    var body: some View {
        Text(message)
    }
}

struct SimpleMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMessageView(message: "No adventure selected")
    }
}
