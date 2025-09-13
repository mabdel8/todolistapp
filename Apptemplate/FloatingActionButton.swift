//
//  FloatingActionButton.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    FloatingActionButton {
        print("FAB tapped")
    }
}