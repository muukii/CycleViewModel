//
// Copyright (c) 2020 muukii
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

/// A metadata object that indicates the name of the mutation and where it was caused.
public struct MutationMetadata: JSONDescribing {
    
  public let createdAt: Date = .init()
  public let name: String
  public let file: StaticString
  public let function: StaticString
  public let line: UInt
  public let context: DispatcherMetadata?
  
  static func makeOnCurrentThread(
    name: String,
    file: StaticString,
    function: StaticString,
    line: UInt,
    context: DispatcherMetadata?
  ) -> Self {
    
    self.init(
      name: name,
      file: file,
      function: function,
      line: line,
      context: contextMetadataRedirectingOnCrrentThread ?? context
    )
  }
  
  public func jsonDescriptor() -> [String : Any]? {
    [
      "createdAt" : VergeStoreStatic.dateFormatter.string(from: createdAt),
      "name" : name,
      "file" : file.description,
      "function" : function.description,
      "line" : line,
      "context" : context?.jsonDescriptor() as Any
    ]
  }
     
}
