//
//  SegmentedControlWidget.swift
//  InstantSearch
//
//  Created by Guy Daher on 05/05/2017.
//
//

import Foundation
import UIKit

@IBDesignable
@objc public class SegmentedControlWidget: UISegmentedControl, FacetControlViewDelegate, AlgoliaWidget {
    
    private var oldSegmentedIndex: Int = UISegmentedControlNoSegment
    private var actualSegmentedIndex: Int = UISegmentedControlNoSegment
    
    // TODO: Need to override for TwoValuesSwitch
    open func set(value: String) {
        for index in 0..<numberOfSegments {
            if value == titleForSegment(at: index) {
                self.oldSegmentedIndex = self.actualSegmentedIndex;
                self.actualSegmentedIndex = self.selectedSegmentIndex;
                return
            }
        }
    }
    
    open func setup() {
        addTarget(self, action: #selector(facetValueChanged), for: .valueChanged)
        if selectedSegmentIndex != UISegmentedControlNoSegment {
            viewModel.addFacet(value: titleForSegment(at: self.actualSegmentedIndex)!)
        }
    }
    
    @objc private func facetValueChanged() {
        guard self.selectedSegmentIndex != UISegmentedControlNoSegment else { return }
        
        self.oldSegmentedIndex = self.actualSegmentedIndex;
        self.actualSegmentedIndex = self.selectedSegmentIndex;
        
        if self.oldSegmentedIndex == UISegmentedControlNoSegment {
            viewModel.addFacet(value: titleForSegment(at: self.actualSegmentedIndex)!)
        } else {
            viewModel.updatefacet(oldValue: titleForSegment(at: self.oldSegmentedIndex)!, newValue: titleForSegment(at: self.actualSegmentedIndex)!)
        }
    }
    
    var viewModel: FacetControlViewModelDelegate
    
    public override init(frame: CGRect) {
        viewModel = FacetControlViewModel()
        super.init(frame: frame)
        viewModel.view = self
        actualSegmentedIndex = self.selectedSegmentIndex
    }
    
    // TODO: Do we need this? when is this actually being called? careful...
    public required init?(coder aDecoder: NSCoder) {
        viewModel = FacetControlViewModel()
        super.init(coder: aDecoder)
        viewModel.view = self
        actualSegmentedIndex = self.selectedSegmentIndex
    }
    
    @IBInspectable public var attributeName: String = ""
    
    internal var operation: String = "equal"
    
    // TODO: Check if this is still needed
    open func getValue() -> String {
        return titleForSegment(at: self.actualSegmentedIndex)!
    }
    
    // TODO: Do something about this...
    public var inclusive: Bool = false
}
