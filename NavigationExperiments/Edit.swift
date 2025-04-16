import SwiftUI

@MainActor
class EditModel: ObservableObject, Identifiable {
    enum Destination {
        case onboardingState(OnboardingFlowStateModel)
        case onboardingObservable(OnboardingFlowObservableModel)
        case onboardingObserved(OnboardingFlowObservedModel)
        case naiveSafari(NaiveSafariView.Configuration)
        case safariView(SafariView.Configuration)
    }

    @Published var destination: Destination?

    init() {
        print("🤯 changed INIT DummyEditModel")
    }

    var onboardingFlowStateModel: OnboardingFlowStateModel? {
        get { if case .onboardingState(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .onboardingState($0)} }
    }

    var onboardingFlowObservableModel: OnboardingFlowObservableModel? {
        get { if case .onboardingObservable(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .onboardingObservable($0)} }
    }

    var onboardingFlowObservedModel: OnboardingFlowObservedModel? {
        get { if case .onboardingObserved(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .onboardingObserved($0)} }
    }

    var naiveSafariModel: NaiveSafariView.Configuration? {
        get { if case .naiveSafari(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .naiveSafari($0)} }
    }

    var safariViewModel: SafariView.Configuration? {
        get { if case .safariView(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .safariView($0)} }
    }

    func onboardingFlowStateButtonTapped() {
        let model = OnboardingFlowStateModel()
        destination = .onboardingState(model)
    }

    func onboardingFlowObservableButtonTapped() {
        let model = OnboardingFlowObservableModel()
        destination = .onboardingObservable(model)
    }

    func onboardingFlowObservedButtonTapped() {
        let model = OnboardingFlowObservedModel()
        destination = .onboardingObserved(model)
    }

    func naiveSafariButtonTapped() {
        let model = NaiveSafariView.Configuration(url: URL(string: "https://google.com")!)
        destination = .naiveSafari(model)
    }

    func safariViewButtonTapped() {
        let model = SafariView.Configuration(url: URL(string: "https://google.com")!)
        destination = .safariView(model)
    }

    func safariViewModalButtonTapped() {
        let model = SafariView.Configuration(
            url: URL(string: "https://google.com")!,
            preferModalPresentation: true
        )
        destination = .safariView(model)
    }
}

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var model: EditModel

    @State var counter: Int = 0

    var body: some View {
        let _ = EditView._printChanges()
        VStack(spacing: 16) {
            HStack {
                Button("decrement") {
                    counter -= 1
                }
                Text("Counter: \(counter)")
                Button("increment") {
                    counter += 1
                }
            }
            Button("Onboarding @State") {
                model.onboardingFlowStateButtonTapped()
            }
            .fullScreenCover(item: $model.onboardingFlowStateModel) { model in
                NavigationStack {
                    OnboardingFlowStateView(model: model)
                }
            }
            Button("Onboarding @Observable Macro") {
                model.onboardingFlowObservableButtonTapped()
            }
            .fullScreenCover(item: $model.onboardingFlowObservableModel) { _ in
                NavigationStack {
                    OnboardingFlowObservableView()
                }
            }
            Button("Onboarding @ObservedObject") {
                model.onboardingFlowObservedButtonTapped()
            }
            .fullScreenCover(item: $model.onboardingFlowObservedModel) { model in
                NavigationStack {
                    OnboardingFlowObservedView(model: model)
                }
            }

            Button("NaiveSafari") {
                model.naiveSafariButtonTapped()
            }
            .fullScreenCover(item: $model.naiveSafariModel) { model in
                NaiveSafariView(configuration: model)
                    .ignoresSafeArea()
            }

            Button("SafariView") {
                model.safariViewButtonTapped()
            }
            .safariView(configuration: $model.safariViewModel)

            Button("SafariViewModal") {
                model.safariViewModalButtonTapped()
            }

        }
        .navigationTitle("DummyEditView")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .padding()
        .background(
            Color.random.opacity(0.2)
        )
    }
}

#Preview {
    NavigationStack {
        EditView(model: EditModel())
    }
}
