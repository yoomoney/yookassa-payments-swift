import UIKit

class TableViewController: UITableViewController {

    private enum Constants {
        static let headerFooterEstimatedHeight: CGFloat = 60.0
    }

    public var sections: [SectionDescriptor] = []

    public func reload(force: Bool = false) {
        tableView.reloadData()
        if force {
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }

    public func reloadTable() {
        tableView.reloadData()
    }

    private var registeredCellIdentifiers = Set<String>()

    func cellDescriptor(for indexPath: IndexPath) -> CellDescriptor {
        return sections[indexPath.section].rows[indexPath.row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: TextHeaderFooterView.identifier)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        subscribeToNotifications()
    }

    override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let descriptor = cellDescriptor(for: indexPath)

        return descriptor.cellClass.estimatedCellHeight
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let descriptor = cellDescriptor(for: indexPath)

        descriptor.selection?(indexPath)
    }

    override public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let descriptor = cellDescriptor(for: indexPath)

        if descriptor.selection == nil {
            return nil
        }

        return indexPath
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerFooterView(with: sections[section].headerText, for: tableView)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return headerFooterView(with: sections[section].footerText, for: tableView)
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerFooterEstimatedHeight
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return Constants.headerFooterEstimatedHeight
    }

    private func headerFooterView(with text: String?, for tableView: UITableView) -> UIView? {
        guard let text = text else {
            return nil
        }

        let header = tableView.dequeueReusableHeaderFooterView(withType: TextHeaderFooterView.self)

        header.title = text

        return header
    }

    private func registerCellIfNeeded(from descriptor: CellDescriptor, in tableView: UITableView) {
        let cellClass = descriptor.cellClass

        guard registeredCellIdentifiers.contains(cellClass.identifier) == false else {
            return
        }

        registeredCellIdentifiers.insert(cellClass.identifier)
        tableView.register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = sections[section]

        return currentSection.rows.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descriptor = cellDescriptor(for: indexPath)

        registerCellIfNeeded(from: descriptor, in: tableView)

        let cell = tableView.dequeueReusableCell(withType: descriptor.cellClass, for: indexPath)

        descriptor.configuration(cell)

        return cell
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUIContentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func cancelNotificationsSubscriptions() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
                                                  object: nil)
    }

    @objc
    private func onUIContentSizeCategoryDidChange() {
        tableView.reloadData()
    }

    // MARK: - Responding to a Change in the Interface Environment

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}
