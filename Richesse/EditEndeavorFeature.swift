//
//  EditEndeavorFeature.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 24/04/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditEndeavorFeature {
    @ObservableState
    struct State: Equatable {
        var endeavor: Endeavor
        var focusField: Field? = nil

        enum Field: String, Hashable {
            case name
        }
    }

    enum Action {
        case setFocusField(State.Field?)
        case setName(String)
        case saveChangesTriggered
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case saveChanges(Endeavor)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setFocusField(let field):
                state.focusField = field
                return .none
            case .setName(let name):
                state.endeavor.name = name
                return .none
            case .delegate:
                return .none
            case .saveChangesTriggered:
                return .run { [endeavor = state.endeavor] send in
                    await send(.delegate(.saveChanges(endeavor)))
                    await dismiss()
                }
            }
        }
    }
}

struct EndeavorEditView: View {
    @Bindable var store: StoreOf<EditEndeavorFeature>

    var body: some View {
        VStack {
            TextField("Name", text: $store.endeavor.name.sending(\.setName))
                .onSubmit {
                    store.send(.saveChangesTriggered)
                }
        }
    }
}
