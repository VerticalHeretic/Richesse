//
//  ActionsFeature.swift
//  Richesse
//
//  Created by Łukasz Stachnik on 23/04/2024.
//

import ComposableArchitecture
import SwiftUI

struct Endeavor: Equatable, Identifiable {
    let id: UUID
    var name: String
    var duration: Duration?
    var completed = false
}

@Reducer
struct EndeavorsFeature {
    @ObservableState
    struct State: Equatable {
        var endeavors: IdentifiedArrayOf<Endeavor> = []
        @Presents var destination: Destination.State?
    }

    enum Action {
        case addButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let endeavor = Endeavor(id: uuid(), name: "")
                state.destination = .editEndeavor(EditEndeavorFeature.State(endeavor: endeavor))
                return .none
            case let .destination(.presented(.editEndeavor(.delegate(.saveChanges(endeavor))))):
                if let index = state.endeavors.index(id: endeavor.id) {
                    state.endeavors[index] = endeavor
                } else {
                    state.endeavors.append(endeavor)
                }
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension EndeavorsFeature {
    @Reducer(state: .equatable)
    enum Destination {
        case editEndeavor(EditEndeavorFeature)
    }
}

struct EndeavorsView: View {
    @Bindable var store: StoreOf<EndeavorsFeature>

    var body: some View {
        List {
            // TODO: Add adding endeavor button/view
            ForEach(store.endeavors) { endeavor in
                HStack {
                    Image(systemName: endeavor.completed ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            // TODO: Add complete action and some animation
                        }

                    VStack(alignment: .leading) {
                        Text(endeavor.name)
                            .border(.red)
                        if let duration = endeavor.duration {
                            Text(duration, format: .time(pattern: .hourMinute))
                                .font(.footnote)
                                .border(.blue)
                        }
                    }
                }
            }
        }
        .sheet(item: $store.scope(
            state: \.destination?.editEndeavor,
            action: \.destination.editEndeavor
        )) { editStore in
            EndeavorEditView(store: editStore)
        }
    }
}



#Preview {
    EndeavorsView(store: Store(initialState: EndeavorsFeature.State(
        endeavors: [
            Endeavor(id: .init(), name: "Create a list of Endeavors", duration: .minutes(60)),
            Endeavor(id: .init(), name: "Add plus button", duration: .minutes(60)),
            Endeavor(id: .init(), name: "Add Endeavors count in the corner", duration: .minutes(60)),
            Endeavor(id: .init(), name: "Add ability to delete Endeavor", duration: .minutes(60))
        ]
    )) {
        EndeavorsFeature()
    })
}

extension Duration {
    static func minutes(_ minutes: Double) -> Duration {
        .seconds(minutes * 60)
    }
}
