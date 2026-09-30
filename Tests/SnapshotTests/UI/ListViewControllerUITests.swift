//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import SnapshotTesting
import XCTest

final class ListViewControllerUITests: XCTestCase {

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testUIConfiguration() {
        var listComponentStyle = ListComponentStyle()
        listComponentStyle.backgroundColor = .red
        
        // Section header
        listComponentStyle.sectionHeader.title.color = .white
        listComponentStyle.sectionHeader.title.backgroundColor = .red
        listComponentStyle.sectionHeader.title.textAlignment = .center
        listComponentStyle.sectionHeader.title.font = .systemFont(ofSize: 22)
        listComponentStyle.sectionHeader.backgroundColor = .brown
        
        var footerStyle = ListSectionFooterStyle()
        footerStyle.title.color = .cyan
        footerStyle.title.backgroundColor = .brown
        footerStyle.title.textAlignment = .left
        footerStyle.title.font = .systemFont(ofSize: 19)
        footerStyle.backgroundColor = .yellow
        
        // List items are themed rather than styled per item.
        let theme = CheckoutTheme(
            colors: CheckoutColors(background: .magenta, container: .magenta)
        )

        let sut = ListViewController(style: listComponentStyle, theme: theme)
        
        let item11 = ListItem(title: "test title 11")
        item11.identifier = "11"
        let item12 = ListItem(title: "test title 12")
        item12.identifier = "12"
        let section1 = ListSection(
            header: ListSectionHeader(title: "section 1", style: listComponentStyle.sectionHeader),
            items: [item11, item12],
            footer: ListSectionFooter(title: "section 1 footer", style: footerStyle)
        )
        
        let item21 = ListItem(title: "test title 21")
        item21.identifier = "21"
        let item22 = ListItem(title: "test title 22")
        item22.identifier = "22"
        let section2 = ListSection(
            header: ListSectionHeader(title: "section 2", style: listComponentStyle.sectionHeader),
            items: [item21, item22]
        )
        
        sut.reload(newSections: [section1, section2])
        
        setupRootViewController(sut)
        
        assertViewControllerImage(matching: sut, named: "listViewController_UI_Configuration")
    }

}
