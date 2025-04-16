import SwiftUI

@MainActor
@Observable
class OnboardingFlowObservableModel: Identifiable {
    enum Destination: Equatable {
        case naiveSafari(NaiveSafariView.Configuration)
        case safariView(SafariView.Configuration)
    }

    var destination: Destination?
    var counter: Int = 0

    init() {
        print("🤯 changed INIT DummyOnboardingFlowModel")
    }

    var naiveSafariModel: NaiveSafariView.Configuration? {
        get { if case .naiveSafari(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .naiveSafari($0)} }
    }

    var safariViewModel: SafariView.Configuration? {
        get { if case .safariView(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .safariView($0)} }
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

struct OnboardingFlowObservableView: View {
    @Environment(\.dismiss) var dismiss
    @State var model = OnboardingFlowObservableModel()

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 16) {
            HStack {
                Button("increment") {
                    model.counter += 1
                }
                Text("Counter: \(model.counter)")
                Button("decrement") {
                    model.counter -= 1
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
        .navigationTitle("@Observable OnboardingView")
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
        OnboardingFlowObservableView(model: OnboardingFlowObservableModel())
    }
}
