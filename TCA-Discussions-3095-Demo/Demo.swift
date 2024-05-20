import ComposableArchitecture

// MARK: Model

struct Child: Equatable, Codable, Identifiable {
    var id = UUID()
}

// MARK: TCA

@Reducer
struct ChildFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        @Shared var child: Child
        var id: UUID { child.id }

        var isLoading: Bool = false
    }
}

@Reducer
struct ParentFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("TestingChildren")) var children: IdentifiedArrayOf<Child> = [
            Child(id: UUID()),
            Child(id: UUID()),
            Child(id: UUID()),
        ]
        var childFeatures: IdentifiedArrayOf<ChildFeature.State> = []

        var isLoading: Bool = false
    }

    @CasePathable
    public enum Action: Equatable {
        case childFeatures(IdentifiedActionOf<ChildFeature>)
    }

    var body: some Reducer<State, Action> {
        EmptyReducer()
            .forEach(\.childFeatures, action: \.childFeatures) { ChildFeature() }
    }
}

// MARK: View

import SwiftUI

struct ParentDemoView: View {
    @Bindable var store: StoreOf<ParentFeature> = Store(initialState: ParentFeature.State()) { ParentFeature() }

    var body: some View {
        List {
            ForEach(store.scope(state: \.childFeatures, action: \.childFeatures)) { store in
                ChildDemoView(store: store)
            }
        }
    }
}

struct ChildDemoView: View {
    @Bindable var store: StoreOf<ChildFeature>

    var body: some View {
        Text("Child \(store.child.id)")
    }
}

// MARK: Preview

#Preview {
    ParentDemoView()
}
