import UIKit

class GoodPracticesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
    }

    private func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // MARK: - BEIGE BLOCK
        let beigeContainer = UIView()
        beigeContainer.backgroundColor = UIColor.appBeigeClair2
        beigeContainer.translatesAutoresizingMaskIntoConstraints = false

        let beigeStack = UIStackView()
        beigeStack.axis = .vertical
        beigeStack.spacing = 20
        beigeStack.alignment = .fill
        beigeStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        beigeStack.isLayoutMarginsRelativeArrangement = true
        beigeStack.translatesAutoresizingMaskIntoConstraints = false
        beigeContainer.addSubview(beigeStack)

        NSLayoutConstraint.activate([
            beigeStack.topAnchor.constraint(equalTo: beigeContainer.topAnchor),
            beigeStack.bottomAnchor.constraint(equalTo: beigeContainer.bottomAnchor),
            beigeStack.leadingAnchor.constraint(equalTo: beigeContainer.leadingAnchor),
            beigeStack.trailingAnchor.constraint(equalTo: beigeContainer.trailingAnchor)
        ])

        let title = titleLabel("small_talk_guidelines_title".localized)
        title.setFontTitle(size: 24)
        beigeStack.addArrangedSubview(title)

        let imageView = UIImageView(image: UIImage(named: "ic_puzzle_trio"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 120)
        ])
        beigeStack.addArrangedSubview(imageView)

        beigeStack.addArrangedSubview(descriptionLabel("small_talk_guidelines_intro".localized))

        beigeStack.addArrangedSubview(sectionBox(
            title: "small_talk_what_it_is_title".localized,
            items: [
                "small_talk_what_it_is_item_1".localized,
                "small_talk_what_it_is_item_2".localized,
                "small_talk_what_it_is_item_3".localized
            ],
            icon: "✅"
        ))

        beigeStack.addArrangedSubview(sectionBox(
            title: "small_talk_what_it_is_not_title".localized,
            items: [
                "small_talk_what_it_is_not_item_1".localized,
                "small_talk_what_it_is_not_item_2".localized,
                "small_talk_what_it_is_not_item_3".localized
            ],
            icon: "❌"
        ))

        mainStackView.addArrangedSubview(beigeContainer)

        // MARK: - WHITE BLOCK
        let whiteContainer = UIView()
        whiteContainer.backgroundColor = .white
        whiteContainer.translatesAutoresizingMaskIntoConstraints = false

        let whiteStack = UIStackView()
        whiteStack.axis = .vertical
        whiteStack.spacing = 20
        whiteStack.alignment = .fill
        whiteStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        whiteStack.isLayoutMarginsRelativeArrangement = true
        whiteStack.translatesAutoresizingMaskIntoConstraints = false
        whiteContainer.addSubview(whiteStack)

        NSLayoutConstraint.activate([
            whiteStack.topAnchor.constraint(equalTo: whiteContainer.topAnchor),
            whiteStack.bottomAnchor.constraint(equalTo: whiteContainer.bottomAnchor),
            whiteStack.leadingAnchor.constraint(equalTo: whiteContainer.leadingAnchor),
            whiteStack.trailingAnchor.constraint(equalTo: whiteContainer.trailingAnchor)
        ])

        whiteStack.addArrangedSubview(titleLabel("small_talk_ethics_title".localized))

        whiteStack.addArrangedSubview(ethicBox(
            title: "small_talk_ethics_1_title".localized,
            text: "small_talk_ethics_1_desc".localized
        ))

        whiteStack.addArrangedSubview(ethicBox(
            title: "small_talk_ethics_2_title".localized,
            text: "small_talk_ethics_2_desc".localized
        ))

        whiteStack.addArrangedSubview(ethicBox(
            title: "small_talk_ethics_3_title".localized,
            text: "small_talk_ethics_3_desc".localized
        ))

        whiteStack.addArrangedSubview(ethicBox(
            title: "small_talk_ethics_4_title".localized,
            text: "small_talk_ethics_4_desc".localized
        ))

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Fermer", for: .normal)
        closeButton.backgroundColor = UIColor.systemOrange
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        whiteStack.addArrangedSubview(closeButton)

        mainStackView.addArrangedSubview(whiteContainer)
    }

    private func titleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.setFontTitle(size: 20)
        label.numberOfLines = 0
        return label
    }

    private func descriptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = htmlToAttributedString(text)
        label.setFontBody(size: 15)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }

    private func sectionBox(title: String, items: [String], icon: String) -> UIView {
        let box = UIStackView()
        box.axis = .vertical
        box.spacing = 10
        box.alignment = .leading
        box.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        box.isLayoutMarginsRelativeArrangement = true
        box.backgroundColor = .white
        box.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.setFontTitle(size: 16)
        box.addArrangedSubview(titleLabel)

        for item in items {
            let itemLabel = UILabel()
            itemLabel.text = "\(icon) \(item)"
            itemLabel.setFontBody(size: 15)
            itemLabel.numberOfLines = 0
            box.addArrangedSubview(itemLabel)
        }

        return box
    }

    private func ethicBox(title: String, text: String) -> UIView {
        let box = UIStackView()
        box.axis = .vertical
        box.spacing = 5
        box.alignment = .leading
        box.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        box.isLayoutMarginsRelativeArrangement = true
        box.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        box.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.setFontTitle(size: 16)
        box.addArrangedSubview(titleLabel)

        let bodyLabel = UILabel()
        bodyLabel.text = text
        bodyLabel.setFontBody(size: 15)
        bodyLabel.numberOfLines = 0
        box.addArrangedSubview(bodyLabel)

        return box
    }

    private func htmlToAttributedString(_ html: String) -> NSAttributedString {
        let data = Data(html.utf8)
        if let attributed = try? NSAttributedString(data: data,
                                                    options: [.documentType: NSAttributedString.DocumentType.html,
                                                              .characterEncoding: String.Encoding.utf8.rawValue],
                                                    documentAttributes: nil) {
            return attributed
        }
        return NSAttributedString(string: html)
    }

    @objc private func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
