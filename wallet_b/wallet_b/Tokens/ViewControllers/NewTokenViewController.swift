// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka
import TrustCore
import QRCodeReaderViewController
import PromiseKit
import NVActivityIndicatorView

//protocol NewTokenViewControllerDelegate: class {
//    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController)
//}

class NewTokenViewController: FormViewController,NVActivityIndicatorViewable {

    private var viewModel: NewTokenViewModel

    private struct Values {
        static let contract = "contract"
        static let name = "name"
        static let symbol = "symbol"
        static let decimals = "decimals"
    }

//    weak var delegate: NewTokenViewControllerDelegate?

    private var contractRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.contract) as? TextFloatLabelRow
    }
    private var nameRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.name) as? TextFloatLabelRow
    }
    private var symbolRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.symbol) as? TextFloatLabelRow
    }
    private var decimalsRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.decimals) as? TextFloatLabelRow
    }

    private let token: ERC20Token?

    init(token: ERC20Token?, viewModel: NewTokenViewModel) {
        self.token = token
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        self.tableView.backgroundColor = UIColor(hex: "FAFAFA")
        self.tableView.sectionFooterHeight = 10
        self.tableView.sectionHeaderHeight = 10
        
        let btn1 = UIButton()
        let btn2 = UIButton(type:.custom)
        
        let recipientRightView = FieldAppereance.addressFieldRightView(
            pasteButton: btn1,qrButton: btn2
        )
        
        btn1.addTarget(self, action:#selector(pasteAction), for:.touchUpInside)
        btn2.addTarget(self, action:#selector(openReader), for:.touchUpInside)

        form = Section()

            +++ Section()

            <<< AppFormAppearance.textFieldFloat(tag: Values.contract) { [unowned self] in
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
                $0.title = "合约地址"
                $0.value = self.viewModel.contract
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.name) { [unowned self] in
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = "名称"
                $0.value = self.viewModel.name
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.symbol) { [unowned self] in
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = "符号"
                $0.value = self.viewModel.symbol
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.decimals) { [unowned self] in
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMaxLength(maxLength: 32))
                $0.validationOptions = .validatesOnDemand
                $0.title = "位数"
                $0.cell.textField.keyboardType = .decimalPad
                $0.value = self.viewModel.decimals
            }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finish))

    }

    //添加币种到本地
    @objc func finish() {
        guard form.validate().isEmpty else {
            return
        }

        let contract = contractRow?.value ?? ""
        let name = nameRow?.value ?? ""
        let symbol = symbolRow?.value ?? ""
        let decimals = Int(decimalsRow?.value ?? "") ?? 0

        guard let address = Address(string: contract) else {
            return alert(text: "地址无效")
        }

        let token = ERC20Token(
            contract: address,
            name: name,
            symbol: symbol,
            decimals: decimals
        )
        mainTabBarController.tokensStorage.addCustom(token: token)
        //delegate?.didAddToken(token: token, in: self)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    @objc func pasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return alert(text: "空白的剪贴板")
        }

        guard CryptoAddressValidator.isValidAddress(value) else {
            return alert(text: "地址无效")
        }

        updateContractValue(value: value)
    }
    
    func alert(text: String) {
        let alertController = UIAlertController(title: "提示",
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确认", style: .default, handler: {
            action in
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    private func updateContractValue(value: String) {
        contractRow?.value = value
        contractRow?.reload()
        fetchInfo(for: value)
    }

    private func fetchInfo(for contract: String) {
        //displayLoading()
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
        firstly {
            viewModel.info(for: contract)
        }.done { [weak self] token in
            self?.nameRow?.value = token.name
            self?.decimalsRow?.value = token.decimals.description
            self?.symbolRow?.value = token.symbol
            self?.nameRow?.reload()
            self?.decimalsRow?.reload()
            self?.symbolRow?.reload()
        }.ensure { [weak self] in
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
        }.catch {_ in
            //We could not find any info about this contract.This error is already logged in crashlytics.
        }

    }
    
//    func displayLoading(
//        text: String = String(format: NSLocalizedString("loading.dots", value: "Loading %@", comment: ""), "..."),
//        animated: Bool = true
//        ) {
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: animated)
//        hud.label.text = text
//    }
//
//    func hideLoading(animated: Bool = true) {
//        MBProgressHUD.hide(for: view, animated: animated)
//    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewTokenViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        
        guard let result = QRURLParser.from(string: result) else {
            alert(text: LanguageHelper.getString(key: "不是钱包"))
            return
        }
        updateContractValue(value: result.address)
    }
}
