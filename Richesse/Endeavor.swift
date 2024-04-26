//
//  Endeavor.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 26/04/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Endeavor {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var name = ""
        var duration: Duration?
        var isCompleted = false
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

struct EndeavorView: View {
    @Bindable var store: StoreOf<Endeavor>

    var body: some View {
        HStack {
            Button {
                store.isCompleted.toggle()
            } label: {
                Image(systemName: store.isCompleted ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)

            TextField("Untitled Endeavor", text: $store.name)
        }
    }
}

#Preview {
    EndeavorView(store: Store(initialState: Endeavor.State(id: UUID()), reducer: {
        Endeavor()
    }))
}
