//
//  AppFeature.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 23/04/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    struct State: Equatable {
        var endeavorsPanel = Endeavors.State()
    }

    enum Action {
        case endeavorsPanel(Endeavors.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.endeavorsPanel, action: \.endeavorsPanel) {
            Endeavors()
        }

        Reduce { _, _ in
            .none
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView(sidebar: {
                EndeavorsView(store: store.scope(state: \.endeavorsPanel, action: \.endeavorsPanel))
            }, detail: {
                // TODO: Add calendar view (static)
            })

            HStack {
                Button(action: {
                    store.send(.endeavorsPanel(.addButtonTapped))
                }, label: {
                    Image(systemName: "plus")
                })
                .keyboardShortcut("n")
            }
            .padding()
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State()) {
        AppFeature()
    })
}
