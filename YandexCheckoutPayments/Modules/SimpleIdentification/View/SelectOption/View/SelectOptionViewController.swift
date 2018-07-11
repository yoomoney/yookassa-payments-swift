import Foundation
import UIKit

final class SelectOptionViewController: UITableViewController {

    // MARK: - VIPER module properties

    weak var output: SelectOptionModuleOutput?

    // MARK: - Subviews properties

    private lazy var closeBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings.Close"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(closeBarButtonItemDidPress))

    // MARK: - Data

    var displayItems: [SelectOptionDisplayItem] = []
    var selectOption: SelectOptionDisplayItem?

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = closeBarItem
        setupTableView()
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(SelectOptionTableViewCell.self)
    }

    // MARK: - Actions

    @objc
    private func closeBarButtonItemDidPress() {
        output?.didFinish()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]

        let cell = tableView.dequeueReusableCell(withType: SelectOptionTableViewCell.self)
        cell.configure(item: item)
        cell.setCheck(item.value == selectOption?.value)

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = displayItems[indexPath.row]
        output?.didFinish(with: item)
    }
}
