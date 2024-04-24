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
        var hoverField: Field? = nil

        enum Field: String, Hashable {
            case completeToggle
            case durationMenu
            case name
        }
    }

    enum Action {
        case setFocusField(State.Field?)
        case setHoverField(State.Field?)
        case toggleCompleted
        case setName(String)
        case setDuration(Duration?)
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
            case .toggleCompleted:
                state.endeavor.completed.toggle()
                return .none
            case .setFocusField(let field):
                state.focusField = field
                return .none
            case .setName(let name):
                state.endeavor.name = name
                return .none
            case .setDuration(let duration):
                state.endeavor.duration = duration
                return .none
            case .setHoverField(let field):
                state.hoverField = field
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
            HStack {
                Image(systemName: store.endeavor.completed ? "circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        store.send(.toggleCompleted)
                    }
                    .onHover { hovering in
                        store.send(.setHoverField(hovering ? .completeToggle : nil))
                    }

                TextField("Name", text: $store.endeavor.name.sending(\.setName))
                    .onSubmit {
                        store.send(.saveChangesTriggered)
                    }
                    .onHover { hovering in
                        store.send(.setHoverField(hovering ? .name : nil))
                    }
            }

            Spacer()

            HStack {
                Menu {
                    Button("30m") { store.send(.setDuration(.minutes(30))) }
                    Button("1h") { store.send(.setDuration(.minutes(60))) }
                    Button("2h") { store.send(.setDuration(.minutes(2 * 60))) }
                    Button("3h") { store.send(.setDuration(.minutes(3 * 60))) }
                    Button("4h") { store.send(.setDuration(.minutes(4 * 60))) }
                } label: {
                    if let duration = store.endeavor.duration {
                        Text(duration, format: .time(pattern: .hourMinute))
                    } else {
                        Image(systemName: "hourglass")
                    }
                }
                .border(store.hoverField == .durationMenu ? Color.red : Color.clear)
                .onHover { hovering in
                    store.send(.setHoverField(hovering ? .durationMenu : nil))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)

                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 200, minHeight: 200)
    }
}
