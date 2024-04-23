//
//  AppFeature.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 23/04/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var endeavorsPanel = EndeavorsFeature.State()
    }

    enum Action {
        case endeavorsPanel(EndeavorsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.endeavorsPanel, action: \.endeavorsPanel) {
            EndeavorsFeature()
        }

        Reduce { _, _ in
            return .none
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationSplitView(sidebar: {
            EndeavorsView(store: store.scope(state: \.endeavorsPanel, action: \.endeavorsPanel))
        }, detail: {

        })
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State()) {
        AppFeature()
    })
}
