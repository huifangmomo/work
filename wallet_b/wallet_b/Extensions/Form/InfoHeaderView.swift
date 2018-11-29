// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class InfoHeaderView: UIView {

    let amountLabel = UILabel(frame: .zero)
    let logoImageView = UIImageView(frame: .zero)
    let secImageView = UIImageView(frame: .zero)
    let label = UILabel(frame: .zero)

    override init(frame: CGRect = .zero) {

        super.init(frame: frame)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        
        secImageView.translatesAutoresizingMaskIntoConstraints = false
        secImageView.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2

        addSubview(logoImageView)
        addSubview(secImageView)
        addSubview(label)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 30),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: secImageView.leadingAnchor, constant: 0),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            secImageView.widthAnchor.constraint(equalToConstant: 30),
            secImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            secImageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -20),

            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        backgroundColor = UIColor.white//.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
