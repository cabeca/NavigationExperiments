import SwiftUI
import SafariServices

struct NaiveSafariView: UIViewControllerRepresentable {

    let configuration: Configuration

    public struct Configuration: Hashable, Identifiable {
        public var id: Int {
            hashValue
        }

        let url: URL
        let modalPresentationStyle: UIModalPresentationStyle
        let modalTransitionStyle: UIModalTransitionStyle

        init(
            url: URL,
            modalPresentationStyle: UIModalPresentationStyle = .automatic,
            modalTransitionStyle: UIModalTransitionStyle = .coverVertical
        ) {
            self.url = url
            self.modalPresentationStyle = modalPresentationStyle
            self.modalTransitionStyle = modalTransitionStyle
        }
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: configuration.url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {

    }
}


public extension Color {
    /// Used for debugging purposes. You can set it as background to check if the view is redrawn.
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension UIWindow {

    /// The view controller that was presented modally on top of the window.
    var farthestPresentedViewController: UIViewController? {
        guard let rootViewController = rootViewController else { return nil }
        return Array(sequence(first: rootViewController, next: \.presentedViewController)).last
    }
}

public struct SwiftUISafariViewController: View {

    @State private var url: URL
    private weak var delegate: SFSafariViewControllerDelegate?

    public init(url: URL, delegate: SFSafariViewControllerDelegate? = nil) {
        self._url = State(wrappedValue: url)
        self.delegate = delegate

        print("🤯 changed INIT SwiftUISafariViewController")
    }

    public var body: some View {
        RepresentedSafariViewController(
            url: url,
            delegate: delegate
        )
        .ignoresSafeArea()
    }
}

private struct RepresentedSafariViewController: UIViewControllerRepresentable {

    let url: URL
    weak var delegate: SFSafariViewControllerDelegate?

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safari = SFSafariViewController(url: url)
        safari.delegate = delegate
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

@MainActor
class ChargeModel: ObservableObject {
    enum Destination {
        case edit(EditModel)
        case naiveSafari(NaiveSafariView.Configuration)
        case safariView(SafariView.Configuration)
    }

    @Published var destination: Destination?

    init() {
        print("🤯 changed INIT ChargeModel")
    }

    var editModel: EditModel? {
        get { if case .edit(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .edit($0)} }
    }

    var naiveSafariModel: NaiveSafariView.Configuration? {
        get { if case .naiveSafari(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .naiveSafari($0)} }
    }

    var safariViewModel: SafariView.Configuration? {
        get { if case .safariView(let model) = destination { model } else { nil } }
        set { destination = newValue.map { .safariView($0)} }
    }

    func editButtonTapped() {
        let model = EditModel()
        destination = .edit(model)
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

struct ChargeView: View {
    @ObservedObject var model: ChargeModel

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 16) {
            Button("Dummy Edit NavigationStack") {
                model.editButtonTapped()
            }
            .fullScreenCover(item: $model.editModel) { model in
                NavigationStack {
                    EditView(model: model)
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
        .navigationTitle("ChargeView")
        .padding()
        .background(
            Color.random.opacity(0.2)
        )
    }
}

#Preview {
    NavigationStack {
        ChargeView(model: ChargeModel())
    }
}
