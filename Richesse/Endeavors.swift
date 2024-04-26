//
//  Endeavors.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 23/04/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Endeavors {
    @ObservableState
    struct State: Equatable {
        var endeavors: IdentifiedArrayOf<Endeavor.State> = []
        var selectedEndeavor: Endeavor.State?
    }

    enum Action {
        case addButtonTapped
        case binding(BindingAction<State>)
        case endeavors(IdentifiedActionOf<Endeavor>)
        case endeavorSelected(Endeavor.State?)
        case delete(IndexSet)
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
            case .delete(let indexSet):
                indexSet.forEach {
                    state.endeavors.remove(at: $0)
                }
                return .none
            case .endeavorSelected(let endeavor):
                state.selectedEndeavor = endeavor
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
        List(store.scope(state: \.endeavors, action: \.endeavors), selection: $store.selectedEndeavor.sending(\.endeavorSelected)) { store in
            EndeavorView(store: store)
        }
//        .onAppear {
//            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
//                print(event.keyCode)
//
//                return event
//            }
//        }
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
