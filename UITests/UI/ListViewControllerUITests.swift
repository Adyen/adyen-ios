//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import SnapshotTesting
import XCTest

final class ListViewControllerUITests: XCTestCase {

    func testUIConfiguration() throws {
        var listComponentStyle = ListComponentStyle()
        listComponentStyle.backgroundColor = .red
        
        /// Section header
        listComponentStyle.sectionHeader.title.color = .white
        listComponentStyle.sectionHeader.title.backgroundColor = .red
        listComponentStyle.sectionHeader.title.textAlignment = .center
        listComponentStyle.sectionHeader.title.font = .systemFont(ofSize: 22)
        listComponentStyle.sectionHeader.backgroundColor = .brown
        
        /// list item
        listComponentStyle.listItem.backgroundColor = .magenta
        listComponentStyle.listItem.title.color = .white
        listComponentStyle.listItem.title.backgroundColor = .black
        listComponentStyle.listItem.title.textAlignment = .left
        listComponentStyle.listItem.title.font = .systemFont(ofSize: 30)
        
        listComponentStyle.listItem.subtitle.color = .white
        listComponentStyle.listItem.subtitle.backgroundColor = .black
        listComponentStyle.listItem.subtitle.textAlignment = .left
        listComponentStyle.listItem.subtitle.font = .systemFont(ofSize: 30)
        
        var footerStyle = ListSectionFooterStyle()
        footerStyle.title.color = .cyan
        footerStyle.title.backgroundColor = .brown
        footerStyle.title.textAlignment = .left
        footerStyle.title.font = .systemFont(ofSize: 19)
        footerStyle.backgroundColor = .yellow
        
        let sut = ListViewController(style: listComponentStyle)
        
        let item11 = ListItem(title: "test title 11", style: listComponentStyle.listItem)
        item11.identifier = "11"
        let item12 = ListItem(title: "test title 12", style: listComponentStyle.listItem)
        item12.identifier = "12"
        let section1 = ListSection(header: ListSectionHeader(title: "section 1", style: listComponentStyle.sectionHeader),
                                   items: [item11, item12],
                                   footer: ListSectionFooter(title: "section 1 footer", style: footerStyle))
        
        let item21 = ListItem(title: "test title 21", style: listComponentStyle.listItem)
        item21.identifier = "21"
        let item22 = ListItem(title: "test title 22", style: listComponentStyle.listItem)
        item22.identifier = "22"
        let section2 = ListSection(header: ListSectionHeader(title: "section 2", style: listComponentStyle.sectionHeader),
                                   items: [item21, item22])
        
        sut.reload(newSections: [section1, section2])
        assertViewControllerImage(matching: sut, named: "listViewController_UI_Configuration")
        
    }

}
