//
//  FAQTableView.swift
//  Charging play
//
//  Created by Artem Sherbachuk on 8/26/21.
//

import UIKit

struct FAQQuestion {
    let question: String
    let answer: String
}

final class FAQTableView: UIStackView {

    private lazy var title: UILabel = {
        let label = createLabel(ofSize: 24, withText: "Frequently Asked Questions".localized(), wight: .bold)
        label.textAlignment = .center
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        axis = .vertical
        distribution = .fill
        spacing = 16
        addArrangedSubview(title)
        [question1, question2, question3, question4].forEach { q in
            addArrangedSubview(FAQRowView(question: q))
        }
    }

}

final class FAQRowView: UIStackView {

    private lazy var answerLabel: UILabel = {
        let label = createLabel(ofSize: 18, withText: "", wight: .medium)
        return label
    }()

    required init(coder: NSCoder) { super.init(coder: coder) }
    init(question: FAQQuestion) {
        super.init(frame: .zero)
        axis = .vertical
        distribution = .fill
        spacing = 8

        let questionViews = [createLabel(ofSize: 20, withText: question.question), createExpandButton()]
        let questionStackView = UIStackView(arrangedSubviews: questionViews)
        questionStackView.axis = .horizontal
        questionStackView.distribution = .fill

        addArrangedSubview(questionStackView)

        let answerView = UIView()
        answerView.isHidden = true
        answerView.backgroundColor = .clear
        answerLabel.text = question.answer
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerView.addSubview(answerLabel)
        answerLabel.leadingAnchor.constraint(equalTo: answerView.leadingAnchor, constant: 16).isActive = true
        answerLabel.trailingAnchor.constraint(equalTo: answerView.trailingAnchor, constant: 0).isActive = true
        answerLabel.topAnchor.constraint(equalTo: answerView.topAnchor, constant: 0).isActive = true
        answerLabel.bottomAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 0).isActive = true

        addArrangedSubview(answerView)
    }

    @objc func expandAction(sender: UIButton) {
        guard let answerView = answerLabel.superview else { return }
        answerView.isHidden = !answerView.isHidden
    }

    private func createExpandButton() -> UIButton {
        let button = SpringButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 45).isActive = true
        button.setImage(UIImage(systemName: "plus.circle") , for: .normal)
        button.tintColor = Theme.whiteColor
        button.addTarget(self, action: #selector(expandAction(sender:)),
                         for: .touchUpInside)
        return button
    }
}

private func createLabel(ofSize: CGFloat, withText text: String,
                         wight: UIFont.Weight = .semibold) -> UILabel {
    let label = UILabel()
    label.text = text
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: ofSize, weight: wight)
    return label
}

/*
let question0 = FAQQuestion(question: "What is the difference between 'lifetime option' and subscriptions?".localized(), answer: "The 'lifetime option' means you unlock the app once and forever. If you select subscription option it will renew automatically for your convenience and to avoid any interruption of service. Your subscription can be managed and auto-renewal turned off by going into your iTunes settings after purchase".localized())
*/

let question1 = FAQQuestion(question: "Can I do a refund? How do I get a refund?".localized(), answer: "Yes, you can do a refund any time since all payments are handled by iTunes you need to send a refund request at reportaproblem.apple.com. It might take up to 48 hours to get your refund.".localized())

let question2 = FAQQuestion(question: "How can I cancel my subscription?".localized(), answer: "Go to device Settings -> Press Your Apple Id row -> Subscriptions. All your active subscriptions will be shown there.".localized())

let question3 = FAQQuestion(question: "If I do cancel the subscription will it expire immediately?".localized(), answer: "No, your subscription will remain active until will get reach the expiration date!".localized())

let question4 = FAQQuestion(question: "Why should I go Premium?".localized(), answer: "This is a Premium product. You can find here high quality animations with Premium design and features that don't have any other similar application. Also as a premium member, You will get first priority in the support at any time.".localized())

