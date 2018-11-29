// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct WelcomeViewModel {
    
    var title: String {
        return "Welcome"
    }
    
    var backgroundColor: UIColor {
        return .white
    }
    
    var pageIndicatorTintColor: UIColor {
        return UIColor(hex: "b3ccfc")
    }
    
    var currentPageIndicatorTintColor: UIColor {
        return UIColor(hex: "6798fb")
    }
    
    var numberOfPages = 0
    var currentPage = 0
}
