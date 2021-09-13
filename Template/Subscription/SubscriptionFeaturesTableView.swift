//
//  SubscriptionFeaturesTableView.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/26/21.
//

import UIKit


final class SubscriptionFeaturesTableView: UIStackView,
                                           UITableViewDelegate,
                                           UITableViewDataSource {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var basicTitle: UILabel!
    @IBOutlet weak var premiumTitle: UILabel!
    @IBOutlet weak var featuresTableView: UITableView!
    @IBOutlet weak var featuresTableViewHeight: NSLayoutConstraint!

    struct Feature {
        let cellId = "FeatureRow"
        let title: String
        let basic: String
        let premium: String
    }

    var features: [Feature] = [] {
        didSet {
            featuresTableView.reloadData()
            featuresTableViewHeight.constant = featuresTableView.contentSize.height + 100
            layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        featuresTableView.allowsSelection = false
        featuresTableView.delegate = self
        featuresTableView.dataSource = self
        title.text = "Basic vs Premium".localized()
        basicTitle.text = "Basic".localized()
        premiumTitle.text = "Premium".localized()
        features = [feature0, feature1, feature2, feature3, feature4, feature5, feature6, feature7, feature8, feature9]
    }

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return features.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feature = features[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: feature.cellId) as! SubscriptionFeatureTableViewCell
        cell.title.text = feature.title
        cell.basic.text = feature.basic
        cell.premium.text = feature.premium
        return cell
    }
}

final class SubscriptionFeatureTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var basic: UILabel!
    @IBOutlet weak var premium: UILabel!
}

let feature0 = SubscriptionFeaturesTableView.Feature(title: "Animations library".localized(), basic: "1", premium: "unlimited".localized())
let feature1 = SubscriptionFeaturesTableView.Feature(title: "SorryLowBattery".localized(), basic: "🔒", premium: "✅".localized())
let feature2 = SubscriptionFeaturesTableView.Feature(title: "Add own background from photo library".localized(), basic: "🔒", premium: "✅")
let feature3 = SubscriptionFeaturesTableView.Feature(title: "Add own music from music library".localized(), basic: "🔒", premium: "✅")
let feature4 = SubscriptionFeaturesTableView.Feature(title: "Video to Live Photo".localized(), basic: "🔒", premium: "✅")
let feature5 = SubscriptionFeaturesTableView.Feature(title: "Select different UI animations".localized(), basic: "🔒", premium: "✅")
let feature6 = SubscriptionFeaturesTableView.Feature(title: "Change UI elements of the charging screen".localized(), basic: "🔒", premium: "✅")
let feature7 = SubscriptionFeaturesTableView.Feature(title: "Change battery indicator view".localized(), basic: "🔒", premium: "✅")
let feature8 = SubscriptionFeaturesTableView.Feature(title: "Add your name on animation screen".localized(), basic: "🔒", premium: "✅")
let feature9 = SubscriptionFeaturesTableView.Feature(title: "Remove Ads".localized(), basic: "🔒", premium: "✅")
