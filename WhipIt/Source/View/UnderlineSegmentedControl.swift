//
//  UnderlineSegmentedControl.swift
//  WhipIt
//
//  Created by Chaewon on 12/21/23.
//

import UIKit

final class UnderlineSegmentedControl: UISegmentedControl {
    
    private lazy var buttonBar = {
        let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let height = 3.0
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.bounds.size.height - height
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = .black
        self.addSubview(view)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)

        setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)

        setTitleTextAttributes([
            NSAttributedString.Key.font : Font.bold14,
            NSAttributedString.Key.foregroundColor : UIColor.lightGray
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.font : Font.bold14,
            NSAttributedString.Key.foregroundColor : UIColor.black
        ], for: .selected)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for segmentviews in self.subviews {
            for segmentLabel in segmentviews.subviews {
                if segmentLabel is UILabel {
                    (segmentLabel as! UILabel).numberOfLines = 0
                }
            }
        }
        
        let barFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = barFinalXPosition
        }
        
       
    }
    
}
