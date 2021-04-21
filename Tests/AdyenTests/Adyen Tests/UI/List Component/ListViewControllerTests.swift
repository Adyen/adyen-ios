//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
import XCTest

class ListViewControllerTests: XCTestCase {
    
    func testUIConfiguration() {
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
        
        let sut = ListViewController(style: listComponentStyle)
        
        let item11 = ListItem(title: "test title 11", style: listComponentStyle.listItem)
        item11.identifier = "11"
        let item12 = ListItem(title: "test title 12", style: listComponentStyle.listItem)
        item12.identifier = "12"
        let section1 = ListSection(title: "section 1", items: [item11, item12])
        
        let item21 = ListItem(title: "test title 21", style: listComponentStyle.listItem)
        item21.identifier = "21"
        let item22 = ListItem(title: "test title 22", style: listComponentStyle.listItem)
        item22.identifier = "22"
        let section2 = ListSection(title: "section 2", items: [item21, item22])
        
        sut.sections = [section1, section2]
        
        UIApplication.shared.keyWindow?.rootViewController = sut
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let listCell11 = sut.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ListCell
            let listView11TitleLabel: UILabel? = sut.view.findView(with: "11.titleLabel")
            let listView11SubtitleLabel: UILabel? = sut.view.findView(with: "11.subtitleLabel")
            
            let listCell12 = sut.tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ListCell
            let listView12TitleLabel: UILabel? = sut.view.findView(with: "12.titleLabel")
            let listView12SubtitleLabel: UILabel? = sut.view.findView(with: "12.subtitleLabel")
            
            let listCell21 = sut.tableView.cellForRow(at: IndexPath(item: 0, section: 1)) as? ListCell
            let listView21TitleLabel: UILabel? = sut.view.findView(with: "21.titleLabel")
            let listView21SubtitleLabel: UILabel? = sut.view.findView(with: "21.subtitleLabel")
            
            let listCell22 = sut.tableView.cellForRow(at: IndexPath(item: 1, section: 1)) as? ListCell
            let listView22TitleLabel: UILabel? = sut.view.findView(with: "22.titleLabel")
            let listView22SubtitleLabel: UILabel? = sut.view.findView(with: "22.subtitleLabel")
            
            let headerView1 = sut.view.findView(with: "Adyen.ListViewController.headerView.0")
            let headerView1TitleLabel: UILabel? = sut.view.findView(with: "Adyen.ListHeaderView.section 1.titleLabel")
            let headerView2 = sut.view.findView(with: "Adyen.ListViewController.headerView.1")
            let headerView2TitleLabel: UILabel? = sut.view.findView(with: "Adyen.ListHeaderView.section 2.titleLabel")
            
            /// list item
            XCTAssertEqual(listCell11?.backgroundColor, .magenta)
            XCTAssertEqual(listCell12?.backgroundColor, .magenta)
            XCTAssertEqual(listCell21?.backgroundColor, .magenta)
            XCTAssertEqual(listCell22?.backgroundColor, .magenta)
            
            XCTAssertEqual(listView11TitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView12TitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView21TitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView22TitleLabel?.backgroundColor, .black)
            
            XCTAssertEqual(listView11TitleLabel?.textColor, .white)
            XCTAssertEqual(listView12TitleLabel?.textColor, .white)
            XCTAssertEqual(listView21TitleLabel?.textColor, .white)
            XCTAssertEqual(listView22TitleLabel?.textColor, .white)
            
            XCTAssertEqual(listView11TitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView12TitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView21TitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView22TitleLabel?.textAlignment, .left)
            
            XCTAssertEqual(listView11TitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView12TitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView21TitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView22TitleLabel?.font, .systemFont(ofSize: 30))
            
            XCTAssertEqual(listView11SubtitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView12SubtitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView21SubtitleLabel?.backgroundColor, .black)
            XCTAssertEqual(listView22SubtitleLabel?.backgroundColor, .black)
            
            XCTAssertEqual(listView11SubtitleLabel?.textColor, .white)
            XCTAssertEqual(listView12SubtitleLabel?.textColor, .white)
            XCTAssertEqual(listView21SubtitleLabel?.textColor, .white)
            XCTAssertEqual(listView22SubtitleLabel?.textColor, .white)
            
            XCTAssertEqual(listView11SubtitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView12SubtitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView21SubtitleLabel?.textAlignment, .left)
            XCTAssertEqual(listView22SubtitleLabel?.textAlignment, .left)
            
            XCTAssertEqual(listView11SubtitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView12SubtitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView21SubtitleLabel?.font, .systemFont(ofSize: 30))
            XCTAssertEqual(listView22SubtitleLabel?.font, .systemFont(ofSize: 30))
            
            /// list section header
            XCTAssertEqual(headerView1?.backgroundColor, .brown)
            XCTAssertEqual(headerView2?.backgroundColor, .brown)
            
            XCTAssertEqual(headerView1TitleLabel?.textColor, .white)
            XCTAssertEqual(headerView1TitleLabel?.textAlignment, .center)
            XCTAssertEqual(headerView1TitleLabel?.font, .systemFont(ofSize: 22))
            XCTAssertEqual(headerView1TitleLabel?.backgroundColor, .red)
            
            XCTAssertEqual(headerView2TitleLabel?.textColor, .white)
            XCTAssertEqual(headerView2TitleLabel?.textAlignment, .center)
            XCTAssertEqual(headerView2TitleLabel?.font, .systemFont(ofSize: 22))
            XCTAssertEqual(headerView2TitleLabel?.backgroundColor, .red)
            
            /// background color
            XCTAssertEqual(sut.view.backgroundColor, .red)
            XCTAssertEqual(sut.tableView.backgroundColor, .red)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
}
