//
// Copyright (c) 2019 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

fileprivate struct Wrapper<Schema: EntitySchemaType> {
  
  var base: Any
  private let _apply: (Any, BackingRemovingEntityStorage<Schema>) -> Any
  
  init<I: IndexType>(
    base: I,
    apply: @escaping (I, BackingRemovingEntityStorage<Schema>) -> I
  ) {
    
    self.base = base
    self._apply = { base, removing -> Any in
      apply(base as! I, removing)
    }
  }
  
  mutating func apply(removing: BackingRemovingEntityStorage<Schema>) {
    self.base = _apply(base, removing)
  }
}

@dynamicMemberLookup
public struct IndexesStorage<Schema: EntitySchemaType, Indexes: IndexesType> {
  
  private typealias Key = AnyKeyPath
  
  private let indexed = Indexes()
  
  private var backing: [Key : Wrapper<Schema>] = [:]
  
  init() {
    
  }
  
  private init(backing: [Key : Wrapper<Schema>]) {
    self.backing = backing
  }
  
}

extension IndexesStorage {
  
  mutating func apply(removing: BackingRemovingEntityStorage<Schema>) {
    backing.keys.forEach { key in
      backing[key]?.apply(removing: removing)
    }
  }
    
  public subscript <Index: IndexType>(dynamicMember keyPath: KeyPath<Indexes, IndexKey<Index>>) -> Index where Index.Schema == Schema {
    get {
      guard let raw = backing[keyPath] else {
        return Index()
      }
      return raw.base as! Index
    }
    mutating set {
      backing[keyPath] = newValue.wrapped()
    }
  }
}

public protocol IndexType {
  
  associatedtype Schema : EntitySchemaType
  
  init()
    
  mutating func _apply(removing: BackingRemovingEntityStorage<Schema>)
}

extension IndexType {

  fileprivate func wrapped() -> Wrapper<Schema> {
    return .init(
      base: self,
      apply: { (base: Self, removing: BackingRemovingEntityStorage<Schema>) in
        var b = base
        b._apply(removing: removing)
        return b
    })
  }
  
}