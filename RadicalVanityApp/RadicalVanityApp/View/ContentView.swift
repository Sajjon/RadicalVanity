//
//  ContentView.swift
//  RadicalVanityApp
//
//  Created by Alexander Cyon on 2023-10-28.
//

import SwiftUI
import RadicalVanity
import IdentifiedCollections

struct ContentView: View {
	@State var model = Model()
	var body: some View {
		TabView {
			SearchTab(model: model)
			ResultTab(model: model)
		}
		.buttonStyle(.borderedProminent)
		.textFieldStyle(.roundedBorder)
	}
}

#Preview {
	ContentView()
}
