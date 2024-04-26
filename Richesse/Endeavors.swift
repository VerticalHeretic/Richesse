//
//  Endeavors.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 23/04/2024.
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

@Reducer
struct Endeavors {
    @ObservableState
    struct State: Equatable {
        var endeavors: IdentifiedArrayOf<Endeavor.State> = []
    }

    enum Action {
        case addButtonTapped
        case binding(BindingAction<State>)
        case endeavors(IdentifiedActionOf<Endeavor>)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.endeavors.append(Endeavor.State(id: uuid()))
                return .none
            case .binding:
                return .none
            case .endeavors:
                return .none
            }
        }
        .forEach(\.endeavors, action: \.endeavors) {
            Endeavor()
        }
    }
}

struct EndeavorsView: View {
    @Bindable var store: StoreOf<Endeavors>

    var body: some View {
        List {
            ForEach(store.scope(state: \.endeavors, action: \.endeavors)) { store in
                EndeavorView(store: store)
            }
        }
    }
}

#Preview {
    EndeavorsView(store: Store(initialState: Endeavors.State(
        endeavors: [
            Endeavor.State(id: UUID(), name: "Get some meat"),
            Endeavor.State(id: UUID(), name: "Make sandwich"),
            Endeavor.State(id: UUID()),
            Endeavor.State(id: UUID())
        ]
    )) {
        Endeavors()
    })
}

extension Duration {
    static func minutes(_ minutes: Double) -> Duration {
        .seconds(minutes * 60)
    }
}
