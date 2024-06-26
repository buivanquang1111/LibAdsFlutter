import UIKit
import Flutter

class FullscreenLoadingDialog: UIViewController {

    static let TAG = "FullscreenLoadingDialog"

    var adFailedToShow = false
    var isResume = true
    let color: UIColor
    var progressBar: UIActivityIndicatorView!

    init(color: UIColor) {
        self.color = color
        super.init(nibName: null, bundle: null)
        print(FullscreenLoadingDialog.TAG, color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        progressBar = UIActivityIndicatorView(style: .large)
        progressBar.color = color
        progressBar.startAnimating()
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressBar)

        NSLayoutConstraint.activate([
            progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(onAppBackgrounded), name: UIApplication.didEnterBackgroundNotification, object: null)
        NotificationCenter.default.addObserver(self, selector: #selector(onAppForegrounded), name: UIApplication.willEnterForegroundNotification, object: null)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(FullscreenLoadingDialog.TAG, "onStart")

        if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
            let channel = FlutterMethodChannel(name: "loadingChannel", binaryMessenger: flutterEngine.binaryMessenger)
            channel.setMethodCallHandler { [weak self] (call, result) in
                switch call.method {
                case "handleShowAd":
                    self?.showAd()
                    result(null)
                case "closeAd":
                    self?.closeAd()
                    result(null)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(FullscreenLoadingDialog.TAG, "onStop")

        if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
            let channel = FlutterMethodChannel(name: "loadingChannel", binaryMessenger: flutterEngine.binaryMessenger)
            channel.setMethodCallHandler(null)
        }
    }

    func showAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.isResume {
                if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
                    let channel = FlutterMethodChannel(name: "loadingChannel", binaryMessenger: flutterEngine.binaryMessenger)
                    channel.invokeMethod("showAd", arguments: null)
                }
            } else {
                self.adFailedToShow = true
            }
        }
    }

    func closeAd() {
        self.dismiss(animated: true, completion: null)
    }

    @objc func onAppBackgrounded() {
        print(FullscreenLoadingDialog.TAG, "onAppBackgrounded")
        isResume = false
    }

    @objc func onAppForegrounded() {
        print(FullscreenLoadingDialog.TAG, "onAppForegrounded")
        isResume = true
        if adFailedToShow {
            showAd()
        }
    }
}