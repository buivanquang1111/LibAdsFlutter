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
        super.init(nibName: nil, bundle: nil)
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

        NotificationCenter.default.addObserver(self, selector: #selector(onAppBackgrounded), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAppForegrounded), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(FullscreenLoadingDialog.TAG, "onStart")


            AmazicPlugin.loadingChannel.setMethodCallHandler { [weak self] (call, result) in
                switch call.method {
                case "handleShowAd":
                    self?.showAd()
                    result(nil)
                case "closeAd":
                    self?.closeAd()
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(FullscreenLoadingDialog.TAG, "onStop")

        AmazicPlugin.loadingChannel.setMethodCallHandler(null)
    }

    func showAd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.isResume {

                    AmazicPlugin.loadingChannel.invokeMethod("showAd", arguments: nil)

            } else {
                self.adFailedToShow = true
            }
        }
    }

    func closeAd() {
        self.dismiss(animated: true, completion: nil)
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