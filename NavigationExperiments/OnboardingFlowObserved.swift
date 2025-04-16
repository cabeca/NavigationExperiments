import SwiftUI

@MainActor
class OnboardingFlowObservedModel: ObservableObject, Identifiable {
    enum Destination: Equatable {
        case naiveSafari(NaiveSafariView.Configuration)
        case safariView(SafariView.Configuration)
    }

    @Published var destination: Destination?
    @Published var counter: Int = 0

    init() {
        print("🤯 changed INIT DummyOnboardingFlowModel")
    }

    func increment() {
        counter += 1
    }

    func decrement() {
        counter -= 1
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

struct OnboardingFlowObservedView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var model: OnboardingFlowObservedModel

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 16) {
            HStack {
                Button("increment") {
                    model.increment()
                }
                Text("Counter: \(model.counter)")
                Button("decrement") {
                    model.decrement()
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
        .navigationTitle("@ObservedObject OnboardingView")
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
        OnboardingFlowObservedView(model: OnboardingFlowObservedModel())
    }
}
