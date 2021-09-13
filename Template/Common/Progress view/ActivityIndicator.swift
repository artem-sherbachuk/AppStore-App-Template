import UIKit

public final class ActivityIndicator {

    static var indicator: NVActivityIndicatorView?

    static func showActivity(topView: UIView,
                             type: NVActivityIndicatorType = .ballScaleMultiple,
                             color: UIColor = Theme.buttonActiveColor,
                             text: String = "") {
        hideActivity()

        let rect = CGRect(x: topView.bounds.midX, y: topView.bounds.midY,
                          width: 300, height: 300)

        let view = NVActivityIndicatorView(frame: rect, type: type, color: color)
        topView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        view.startAnimating()


        let loadingLabel = UILabel()
        loadingLabel.text = text
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        loadingLabel.textColor = color
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingLabel)
        loadingLabel.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.stateLabel = loadingLabel
        ActivityIndicator.indicator = view
        ActivityIndicator.indicator?.startAnimating()
    }

    static func hideActivity() {
        ActivityIndicator.indicator?.stopAnimating()
        ActivityIndicator.indicator?.removeFromSuperview()
        ActivityIndicator.indicator = nil
    }
}
