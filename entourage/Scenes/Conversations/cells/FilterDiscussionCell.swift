import UIKit

protocol FilterDiscussionCellDelegate: AnyObject {
    func onFilterClick(filter: String)
}

class FilterDiscussionCell: UITableViewCell {
    
    // MARK: - Variables
    weak var delegate: FilterDiscussionCellDelegate?
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var selectedFilter: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        scrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(scrollView)

        stackView.axis = .horizontal
        stackView.spacing = 10
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            scrollView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func configure(filters: [String], selectedFilter: String?) {
        self.selectedFilter = selectedFilter
        
        // Nettoyer les boutons précédents
        buttons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for filter in filters {
            let button = UIButton(type: .system)
            configureFilterButton(button, withTitle: filter)
            button.tag = filters.firstIndex(of: filter) ?? 0
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            buttons.append(button)

            // Appliquer le bon état visuel
            updateButtonStyle(button, isSelected: filter == selectedFilter)
        }
    }

    @objc private func filterTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }

        // Met à jour la sélection
        selectedFilter = title

        // Met à jour l'apparence de tous les boutons
        buttons.forEach { updateButtonStyle($0, isSelected: $0.currentTitle == title) }
        
        // Notifie le delegate du changement
        delegate?.onFilterClick(filter: title)
    }
    
    private func configureFilterButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.clipsToBounds = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }
    
    private func updateButtonStyle(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor.appOrangeConversationEventClicked
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor.appOrangeConversationEventUnClicked
            button.setTitleColor(UIColor.appOrange, for: .normal)
        }
    }
}
