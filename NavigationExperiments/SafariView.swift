import SafariServices
import SwiftUI

public struct SafariView: UIViewRepresentable {
    public struct Configuration: Hashable, Identifiable {
        public var id: Int {
            hashValue
        }

        let url: URL
        let preferModalPresentation: Bool

        public init(
            url: URL,
            preferModalPresentation: Bool = false
        ) {
            self.url = url
            self.preferModalPresentation = preferModalPresentation
        }
    }

    private final class SafariViewState {
        let safariViewController: SFSafariViewController
        let delegate: Delegate
        let configuration: Configuration

        init(safariViewController: SFSafariViewController, delegate: Delegate, configuration: Configuration) {
            self.safariViewController = safariViewController
            self.delegate = delegate
            self.configuration = configuration
        }
    }

    static private var state: [Configuration: SafariViewState] = [:]

    @Binding public var configuration: Configuration?
    let onDismiss: (() -> Void)?

    public init(
        configuration: Binding<Configuration?>,
        onDismiss: (() -> Void)?
    ) {
        self._configuration = configuration
        self.onDismiss = onDismiss
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.updatePresentation(from: uiView, configuration: configuration)
        }
    }

    func resetConfiguration(configuration: Configuration) {
        SafariView.state[configuration] = nil
        self.configuration = nil
        onDismiss?()
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    public class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView

        init(parent: SafariView) {
            self.parent = parent
            super.init()
        }

        func updatePresentation(from view: UIView, configuration: Configuration?) {
            guard let presenter = topMostPresentedViewController(for: view) else { return }
            let safariViewState = configuration.flatMap { SafariView.state[$0] }

            switch (configuration, safariViewState) {
            case (.some(let configuration), .none):
                presentSafariViewController(from: presenter, configuration: configuration, animated: true)
            case (.none, .some(let safariViewState)):
                dismissSafariViewController(safariViewState, animated: true)
            case (.some, .some):
                // Changing SafariView.Configuration is not supported yet. As a workaround, dismiss and present with new configuration.
                break
            case (.none, .none):
                break
            }
        }

        private func presentSafariViewController(from presenter: UIViewController, configuration: Configuration, animated: Bool) {
            let safariViewController = SFSafariViewController(url: configuration.url)
            let delegate = Delegate(parent: parent, configuration: configuration)
            safariViewController.delegate = delegate
            if configuration.preferModalPresentation {
                safariViewController.modalPresentationStyle = .overFullScreen
            }
            SafariView.state[configuration] = SafariViewState(
                safariViewController: safariViewController,
                delegate: delegate,
                configuration: configuration
            )
            presenter.present(safariViewController, animated: animated)
        }

        private func dismissSafariViewController(_ safariViewState: SafariViewState, animated: Bool, completion: (() -> Void)? = nil) {
            safariViewState.safariViewController.dismiss(animated: animated) {
                SafariView.state[safariViewState.configuration] = nil
                completion?()
            }
        }

        private func topMostPresentedViewController(for view: UIView) -> UIViewController? {
            guard var current = view.window?.rootViewController else { return nil }
            while let presented = current.presentedViewController {
                current = presented
            }
            return current
        }
    }

    @MainActor
    public class Delegate: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        let configuration: Configuration

        init(parent: SafariView, configuration: Configuration) {
            self.parent = parent
            self.configuration = configuration
            super.init()
        }

        public nonisolated func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            MainActor.assumeIsolated {
                parent.resetConfiguration(configuration: configuration)
            }
        }
    }
}

public struct SafariViewModifier: ViewModifier {
    let configuration: Binding<SafariView.Configuration?>
    let onDismiss: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .background(
                SafariView(configuration: configuration, onDismiss: onDismiss)
            )
    }
}

public extension View {
    func safariView(
        configuration: Binding<SafariView.Configuration?>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(SafariViewModifier(configuration: configuration, onDismiss: onDismiss))
    }
}
