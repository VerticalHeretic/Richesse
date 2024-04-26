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
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        var name = ""
        var duration: Duration?
        var isCompleted = false
        var isSelected = false
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
        HStack(spacing: 8) {
            Button {
                store.isCompleted.toggle()
            } label: {
                Image(systemName: store.isCompleted ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)

            if store.isSelected {
                TextField("Untitled Endeavor", text: $store.name) // TODO: Add focus on appear
            } else {
                Text(store.name)
                    .frame(maxWidth: .infinity)
                    .border(.red)
            }

            Spacer()

            if store.isSelected {
                Menu {
                    Button("0.5h") {
                        store.duration = .minutes(30)
                    }

                    Button("1h") {
                        store.duration = .minutes(60)
                    }

                    Button("1.5h") {
                        store.duration = .minutes(90)
                    }

                    Button("2h") {
                        store.duration = .minutes(120)
                    }
                } label: {
                    if let duration = store.duration {
                        Text(duration, format: .time(pattern: .hourMinute))
                    } else {
                        Image(systemName: "hourglass")
                    }
                }
                .menuIndicator(.hidden)
                .fixedSize()
            } else if let duration = store.duration {
                Text(duration, format: .time(pattern: .hourMinute))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.isSelected.toggle()
        }
    }
}

#Preview {
    EndeavorView(store: Store(initialState: Endeavor.State(id: UUID()), reducer: {
        Endeavor()
    }))
}
