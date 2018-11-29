// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum ResultSection: Int {
    case local = 0
    case remote = 1
}

protocol SearchTokenResultsControllerDelegate: class {
    func searchResultsController(configureCell cell: EditTokenTableViewCell, with token: (token: TokenObject, local: Bool))
    func searchResultsController(didSelect cell: EditTokenTableViewCell, with token: (token: TokenObject, local: Bool))
    func searchResultsController(didUpdate token: TokenObject, with action: TokenAction)
}

class SearchTokenResultsController: UITableViewController {
    weak var delegate: SearchTokenResultsControllerDelegate?
    var localResults: [TokenObject] {
        get {
            return results[ResultSection.local.rawValue]
        }
        set {
            results[ResultSection.local.rawValue] = newValue
            tableView.reloadData()
        }
    }

    var remoteResults: [TokenObject] {
        get {
            return results[ResultSection.remote.rawValue]
        }
        set {
            results[ResultSection.remote.rawValue] = newValue
            tableView.reloadData()
        }
    }

    private var results = [[TokenObject](), [TokenObject]()]
    var imageNil:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if results.count == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return results.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results[section].count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.editTokenTableViewCell.name, for: indexPath) as! EditTokenTableViewCell
        let token = self.token(for: indexPath)
        delegate?.searchResultsController(configureCell: cell, with: token)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < results.count,
            indexPath.row < results[indexPath.section].count else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? EditTokenTableViewCell else {
            return
        }
        let token = self.token(for: indexPath)
        delegate?.searchResultsController(didSelect: cell, with: token)
    }

    private func configureTableView() {
        tableView.register(R.nib.editTokenTableViewCell(), forCellReuseIdentifier: R.nib.editTokenTableViewCell.name)
        tableView.keyboardDismissMode = .onDrag
    }

    private func token(for indexPath: IndexPath) -> (token: TokenObject, local: Bool) {
        let token = results[indexPath.section][indexPath.row]
        return (token: token, local: indexPath.section == ResultSection.local.rawValue)
    }
}

extension SearchTokenResultsController: EditTokenTableViewCellDelegate {
    func didChangeState(state: Bool, in cell: EditTokenTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let token = self.token(for: indexPath)
        delegate?.searchResultsController(didUpdate: token.token, with: .disable(!state))
    }
}
