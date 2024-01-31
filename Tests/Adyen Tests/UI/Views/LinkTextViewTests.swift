//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_documentation(visibility: internal) @testable import Adyen
import XCTest

class LinkTextViewTests: XCTestCase {
    
    func testNoLink() throws {
        
        // Given
        
        let linkTextView = LinkTextView { linkIndex in }
        
        // When
        
        linkTextView.update(
            text: "Hello %@World%@",
            style: .init(font: .boldSystemFont(ofSize: 1), color: .red),
            linkRangeDelimiter: "%#"
        )
        
        // Then
        
        let links = linkTextView.attributedText.links
        
        XCTAssertEqual(links.count, 0)
        XCTAssertEqual(linkTextView.attributedText.string, "Hello %@World%@")
    }
    
    func testSingleLinkWithLinkHandler() throws {
        
        let expectation = expectation(description: "Link handler is called")
        
        // Given
        
        let linkTextView = LinkTextView { linkIndex in
            XCTAssertEqual(linkIndex, 0)
            expectation.fulfill()
        }
        
        // When
        
        linkTextView.update(
            text: "Hello %#World%#",
            style: .init(font: .boldSystemFont(ofSize: 1), color: .red),
            linkRangeDelimiter: "%#"
        )
        
        let result = linkTextView.textView(
            linkTextView,
            shouldInteractWith: URL(string: "0")!,
            in: NSRange(location: 0, length: 1),
            interaction: .preview
        )
        
        // Then
        
        let links = linkTextView.attributedText.links
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(links.count, 1)
        XCTAssertEqual(links.first!, "0")
        XCTAssertEqual(linkTextView.attributedText.string, "Hello World")
        XCTAssertFalse(result)
    }
    
    func testMultipleLinks() throws {
     
        // Given
        
        let linkTextView = LinkTextView { linkIndex in }
        
        linkTextView.update(
            text: "Hello %#World%# %#Foo%# %#Bar%# %#Not A link",
            style: .init(font: .boldSystemFont(ofSize: 1), color: .red),
            linkRangeDelimiter: "%#"
        )
        
        // Then
        
        let links = linkTextView.attributedText.links
        
        XCTAssertEqual(links.count, 3)
        XCTAssertEqual(linkTextView.attributedText.string, "Hello World Foo Bar Not A link")
    }
}

// MARK: - Convenience

private extension NSAttributedString {
    
    var links: [String] {
        var links = [String]()
        let textRange = NSRange(location: 0, length: length)
        enumerateAttributes(in: textRange) { attributes, _, _ in
            attributes.forEach {
                if $0 == .link { links.append($1 as! String) }
            }
        }
        return links
    }
}
