import UIKit

class UnsubscribedParticipantsBottomSheet: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()

    private let helpAskLabel = UILabel()
    private let helpAskMinusButton = UIButton()
    private let helpAskPlusButton = UIButton()
    private let helpAskCountLabel = UILabel()

    private let helpOfferLabel = UILabel()
    private let helpOfferMinusButton = UIButton()
    private let helpOfferPlusButton = UIButton()
    private let helpOfferCountLabel = UILabel()

    private let helpFemaleLabel = UILabel()
    private let helpFemaleMinusButton = UIButton()
    private let helpFemalePlusButton = UIButton()
    private let helpFemaleCountLabel = UILabel()

    private let validateButton = UIButton()

    var initialAskCount: Int = 0
    var initialOfferCount: Int = 0
    var initialFemaleCount: Int = 0

    private var currentAskCount: Int = 0 {
        didSet {
            helpAskCountLabel.text = "\(currentAskCount)"
        }
    }

    private var currentOfferCount: Int = 0 {
        didSet {
            helpOfferCountLabel.text = "\(currentOfferCount)"
        }
    }

    private var currentFemaleCount: Int = 0 {
        didSet {
            helpFemaleCountLabel.text = "\(currentFemaleCount)"
        }
    }

    var onValidate: ((Int, Int, Int) -> Void)?
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        currentAskCount = initialAskCount
        currentOfferCount = initialOfferCount
        currentFemaleCount = initialFemaleCount
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isBeingDismissed {
            onDismiss?()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        titleLabel.text = "Ajouter des participants"
        titleLabel.font = ApplicationTheme.getFontH1Noir().font
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        helpAskLabel.text = "Combien de personnes isolées supplémentaires ont rejoint l'événement ?"
        helpAskLabel.font = ApplicationTheme.getFontCourantRegularNoir().font
        helpAskLabel.textColor = .black
        helpAskLabel.numberOfLines = 0
        helpAskLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(helpAskLabel)

        setupCounter(minusBtn: helpAskMinusButton, plusBtn: helpAskPlusButton, countLabel: helpAskCountLabel, yAnchorView: helpAskLabel)

        helpOfferLabel.text = "Combien de riverains supplémentaires ont rejoint l'événement ?"
        helpOfferLabel.font = ApplicationTheme.getFontCourantRegularNoir().font
        helpOfferLabel.textColor = .black
        helpOfferLabel.numberOfLines = 0
        helpOfferLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(helpOfferLabel)

        setupCounter(minusBtn: helpOfferMinusButton, plusBtn: helpOfferPlusButton, countLabel: helpOfferCountLabel, yAnchorView: helpOfferLabel)

        helpFemaleLabel.text = "Combien de femmes isolées supplémentaires ont rejoint l'événement ?"
        helpFemaleLabel.font = ApplicationTheme.getFontCourantRegularNoir().font
        helpFemaleLabel.textColor = .black
        helpFemaleLabel.numberOfLines = 0
        helpFemaleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(helpFemaleLabel)

        setupCounter(minusBtn: helpFemaleMinusButton, plusBtn: helpFemalePlusButton, countLabel: helpFemaleCountLabel, yAnchorView: helpFemaleLabel)

        validateButton.setTitle("Valider", for: .normal)
        validateButton.backgroundColor = UIColor.appOrange
        validateButton.setTitleColor(.white, for: .normal)
        validateButton.layer.cornerRadius = 25
        validateButton.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        validateButton.clipsToBounds = true
        validateButton.translatesAutoresizingMaskIntoConstraints = false
        validateButton.addTarget(self, action: #selector(validateAction), for: .touchUpInside)
        contentView.addSubview(validateButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            helpAskLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            helpAskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            helpAskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            helpOfferLabel.topAnchor.constraint(equalTo: helpAskLabel.bottomAnchor, constant: 90),
            helpOfferLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            helpOfferLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            helpFemaleLabel.topAnchor.constraint(equalTo: helpOfferLabel.bottomAnchor, constant: 90),
            helpFemaleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            helpFemaleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            validateButton.topAnchor.constraint(equalTo: helpFemaleLabel.bottomAnchor, constant: 100),
            validateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            validateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            validateButton.heightAnchor.constraint(equalToConstant: 50),
            validateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        helpAskMinusButton.addTarget(self, action: #selector(askMinusAction), for: .touchUpInside)
        helpAskPlusButton.addTarget(self, action: #selector(askPlusAction), for: .touchUpInside)

        helpOfferMinusButton.addTarget(self, action: #selector(offerMinusAction), for: .touchUpInside)
        helpOfferPlusButton.addTarget(self, action: #selector(offerPlusAction), for: .touchUpInside)

        helpFemaleMinusButton.addTarget(self, action: #selector(femaleMinusAction), for: .touchUpInside)
        helpFemalePlusButton.addTarget(self, action: #selector(femalePlusAction), for: .touchUpInside)
    }

    private func setupCounter(minusBtn: UIButton, plusBtn: UIButton, countLabel: UILabel, yAnchorView: UIView) {
        let stack = UIStackView(arrangedSubviews: [minusBtn, countLabel, plusBtn])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        minusBtn.setTitle("−", for: .normal)
        minusBtn.setTitleColor(UIColor(named: "appOrange") ?? .orange, for: .normal)
        minusBtn.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        minusBtn.layer.cornerRadius = 20
        minusBtn.backgroundColor = UIColor(named: "orange_light_a50") ?? UIColor.orange.withAlphaComponent(0.1)

        plusBtn.setTitle("+", for: .normal)
        plusBtn.setTitleColor(UIColor(named: "appOrange") ?? .orange, for: .normal)
        plusBtn.titleLabel?.font = .systemFont(ofSize: 24, weight: .regular)
        plusBtn.layer.cornerRadius = 20
        plusBtn.backgroundColor = UIColor(named: "orange_light_a50") ?? UIColor.orange.withAlphaComponent(0.1)

        countLabel.font = ApplicationTheme.getFontH2Noir().font
        countLabel.textColor = .black
        countLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            minusBtn.widthAnchor.constraint(equalToConstant: 40),
            minusBtn.heightAnchor.constraint(equalToConstant: 40),
            plusBtn.widthAnchor.constraint(equalToConstant: 40),
            plusBtn.heightAnchor.constraint(equalToConstant: 40),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),

            stack.topAnchor.constraint(equalTo: yAnchorView.bottomAnchor, constant: 16),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    @objc private func askMinusAction() {
        if currentAskCount > 0 {
            currentAskCount -= 1
        }
    }

    @objc private func askPlusAction() {
        currentAskCount += 1
    }

    @objc private func offerMinusAction() {
        if currentOfferCount > 0 {
            currentOfferCount -= 1
        }
    }

    @objc private func offerPlusAction() {
        currentOfferCount += 1
    }

    @objc private func femaleMinusAction() {
        if currentFemaleCount > 0 {
            currentFemaleCount -= 1
        }
    }

    @objc private func femalePlusAction() {
        currentFemaleCount += 1
    }

    @objc private func validateAction() {
        onValidate?(currentOfferCount, currentAskCount, currentFemaleCount)
        dismiss(animated: true)
    }
}
