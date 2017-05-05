//
//  Copyright (c) 2015 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import InstantSearchCore
import UIKit

private var highlightedBackgroundColorKey: Void?

extension UILabel {
    @objc public var highlightedBackgroundColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &highlightedBackgroundColorKey) as? UIColor
        }
        set(newValue) {
            objc_setAssociatedObject(self, &highlightedBackgroundColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc public var highlightedText: String? {
        get {
            return attributedText?.string
        }
        set {
            let textColor = highlightedTextColor ?? self.tintColor ?? UIColor.blue
            let backgroundColor = highlightedBackgroundColor ?? UIColor.clear
            attributedText = newValue == nil ? nil : Highlighter(highlightAttrs: [NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor]).render(text: newValue!)
        }
    }
}

private class WeakObject<T: AnyObject>: Hashable {
    
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
    
    var hashValue: Int {
        var hashValue = 0
        if var object = object {
            withUnsafePointer(to: &object, {
                hashValue = $0.hashValue
            })
        }
        return hashValue
    }
}

private func == <T> (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
    return lhs.object === rhs.object
}


public struct WeakSet<T: AnyObject>: Sequence {
    
    private var _objects: Set<WeakObject<T>>
    
    public init() {
        _objects = Set<WeakObject<T>>()
    }
    
    public init(_ objects: [T]) {
        self._objects = Set<WeakObject<T>>(objects.map { WeakObject($0) })
    }
    
    public var objects: [T] {
        return _objects.flatMap { $0.object }
    }
    
    public func contains(object: T) -> Bool {
        return self._objects.contains(WeakObject(object))
    }
    
    public mutating func add(_ object: T) {
        _objects.insert(WeakObject(object))
    }
    
    public mutating func add(_ objects: [T]) {
        _objects.formUnion(objects.map { WeakObject($0) })
    }
    
    public mutating func remove(_ object: T) {
        _objects.remove(WeakObject(object))
    }
    
    public mutating func remove(_ objects: [T]) {
        _objects.subtract(objects.map { WeakObject($0) })
    }
    
    public func makeIterator() -> AnyIterator<T> {
        let objects = self.objects
        var index = 0
        return AnyIterator {
            defer { index += 1 }
            return index < objects.count ? objects[index] : nil
        }
    }
}