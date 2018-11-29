// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class FieldAppereance {

    static func addressFieldRightView(
        pasteButton:UIButton,
        qrButton:UIButton
    ) -> UIView {
        
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setTitle("粘贴", for: .normal)
        pasteButton.setTitleColor(UIColor(hex: "6693FF"),for: .normal)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        qrButton.setImage(R.image.btn_scanning_1(), for: .normal)
        qrButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let recipientRightView = UIStackView(arrangedSubviews: [
            pasteButton,
            qrButton,
        ])
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.distribution = .equalSpacing
        recipientRightView.spacing = 2
        recipientRightView.axis = .horizontal
        return recipientRightView
    }
}
