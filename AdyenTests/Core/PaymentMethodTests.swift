//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenInternal
import XCTest

class PaymentMethodTests: XCTestCase {
    func testDecodingCardPaymentMethodFromJSON() throws {
        let paymentMethod = try Coder.decode(resourceNamed: "payment_method_card") as PaymentMethod
        XCTAssertEqual(paymentMethod.type, "amex")
        XCTAssertEqual(paymentMethod.name, "American Express")
        XCTAssertEqual(paymentMethod.details.count, 2)
        XCTAssertEqual(paymentMethod.details[0].key, "additionalData.card.encrypted.json")
        XCTAssertEqual(paymentMethod.details[0].inputType, .cardToken)
        XCTAssertFalse(paymentMethod.details[0].isOptional)
        XCTAssertEqual(paymentMethod.details[1].key, "storeDetails")
        XCTAssertEqual(paymentMethod.details[1].inputType, .boolean)
        XCTAssertTrue(paymentMethod.details[1].isOptional)
        XCTAssertEqual(paymentMethod.group?.type, "card")
        XCTAssertEqual(paymentMethod.group?.name, "Credit Card")
        XCTAssertEqual(paymentMethod.group?.paymentMethodData, "Hee57361f99ddcf4!ZW5jcnlwdGVkPUJRQUJBZ0NmOG45T040R2E0ampoWWxxeSUyQlQ1NUJTNzBWYzRVSk9FYVJLNmd2WXpJdUVLMXVCeThCdnYlMkI2V2l5dEMlMkJyU2lPJTJGYW9RYUt6U3RoY3NwamtZRWVSWTdpZnFNcDBjOGM3NXRsJTJGS0dZc0FrVXJnRHpIcGhwRHNESGc0cDQzMFJ6UVZaS3N5dVZadEQwWjNobDYlMkZXJTJGQUZEcVNpaXdkUzU0eEhkZkFNdUwxWTc0YSUyQk1pczVvMUJ0MXZ3RlZ3ZHZNTDBpUWI5aXF2V3NKQXRydkhlJTJGRTZ6ZGlQSCUyQlloQWJmU1U0VDljWFFxUjMzamlRNmdob3VGWFNZbFo2cFZiSHY5YUFKcmZFVTNBRWphTFNmeFFxSk11MVdMYTdMdnZQT0hRYSUyQmo3QzVYSXV0WGNBOEpQSkcwY1FMdmZDYlpVMGh4RUNSYSUyRjZBck9uZWU5ekpsakRsa3YlMkY1YkNqSFhydGtHaUJQSVJ5UzNLaWZNTGk3a3NwTUJlczBtenQ2T20zaGhJMW5ZTkE4OEtDR29ERGM2WlFkYVdPY1M2QVFzWlBib0ElMkZOTm96MHVXMk9mbTFLVnNyQ0l1Zm16ekNiWCUyQjdqbFFvSWtJb2VtTklDNDRlNzVxaGt0aTBwWUZyRUh4M2UwTURhVm1QbnJCJTJCeXolMkI0QTV3U2dKcGdpNlRDQ1d0JTJCakslMkZIbEpneGMlMkZDeGFFckJHUHlQWTNEYThIY3VrWVZrcmZWc080cE1lTEx3V1dkV0x6WUl1V3dUZyUyQlNhYXNiSlNLTE8zd20yaGx4OSUyRldtV2Vlalp6SE10OTZRSTRzaSUyQnQxeXY2ZDJ3Mnp0YzNBR082b1ZreEpsWlZ6eFUzZjBIbm5aN3VBUHNUNVVkTXFCcGg4YzlEUjlPMiUyQm9QS1poWWZlYVJtOUFzJTJGVk10RzJ4QTQzUWxoNjVoMiUyRkVMSjBhcXFwemFnQUVwN0ltdGxlU0k2SWtGR01FRkJRVEV3TTBOQk5UTTNSVUZGUkRnM1F6STBSRVExTXprd09VSTRNRUUzT0VFNU1qTkZNemd5TTBRMk9FUkJRME01TkVJNVJrWTRNekExUkVNaWZTU2pyejkycCUyQjNmRk9mVXJTam5mblh6WXZZSzVEZngxJTJGSkZFZmxKQTlnUSZ2ZXJzaW9uPTI=")
        XCTAssertEqual(paymentMethod.paymentMethodData, "Hee57361f99ddcf4!ZW5jcnlwdGVkPUJRQUJBZ0I4aHZJVW9zYVJYSkdaVzFnTzRJc0pxMTZiem5mbER4cERoYWN5aXFVaTRMYXklMkZMeUxPeTJ5NUp0dEhZSWJlcHA1NzRvSlJoWlJTZWx6dlVvZnZyb0pOeTBkUzdsR0NXVzYxJTJGcEhlbXJ4cCUyQmd5M0VqbGNCNGlxanZOZlU4JTJGMnBDMjdzN1JOdHpYNXNKWVZhcDBTTVNyQjFqNzNRdEdFMk4lMkY2cFBheG1Zand3OWFZR2tOdUNvVWJVbXdCWlBjZUlCMEtNdUc5ckFiU2gyMjBicE4yR3FsdVBYWCUyRmd3NWZDQVVxVWJNa0xtRXNJaUtjJTJCeTZGZXA3cDl6T3JlaUU0WVdTUm9aejJCUW93TjI2M29YSHJJSEV5TENzQU5sRHV3UjVGZVFxMFRFNGY3MTRPRTJwOGtJblNFeFNCMDBNOU1zUnljTmRsZXAlMkIlMkZpOUkxRTF1ZWl3Y3R2NE9BZmJ1T3o4b2pkR1ptJTJCUjNqdE01RFB6N3BkZ2MyRlVORWM4JTJGZzJSZG00aVU4cFIzZG8yZFE3SzFwR1lBbWpvZyUyRkNTZ1pTdEJlZ3FnMURQeXhPNjRWNWhHVE0yNkNIcmhsOXYwWkklMkJBeUxLMVg4bVNQMVU4T2R3bmZmb2xyaHU0QTc2MzNZMDNLZlMlMkJMZlNJa0JXRTZndm9EVVBFbElBcmxuNlhVSDFGbjNaM3I2UzQlMkJuMTlWZ2glMkZ1N3VIVzFGSW1mQklnRDNyeG45azZVbVVJd2Q4TEJISWV0U01PWUFFUDIyUDQ1VWFRVDdvQzVhcWN6MURxR3ZKZUFrQTQ3UjNRMFl3NG9NOVVBTjJJNEYwcHBvWkxqZnNVSEJYS3RnWWN3byUyRnBvMXNMMDZTTWVBbjViZ0FOJTJGZ0h3SmszJTJGYVJMUjQlMkI2NmU5dkFzckpqbkU1OWhBOXNzMnV2NjN4Vk9ZVjAxYUhuRlhHQUVwN0ltdGxlU0k2SWtGR01FRkJRVEV3TTBOQk5UTTNSVUZGUkRnM1F6STBSRVExTXprd09VSTRNRUUzT0VFNU1qTkZNemd5TTBRMk9FUkJRME01TkVJNVJrWTRNekExUkVNaWZVJTJGRTVzZURVck5MbHZJcVJHbzBDZmZsbjlvUlNlckkwVlJIVmt1ZHlnJTNEJTNEJnZlcnNpb249Mg==")
    }
    
    func testDecodingIdealPaymentMethodFromJSON() throws {
        let paymentMethod = try Coder.decode(resourceNamed: "payment_method_ideal") as PaymentMethod
        XCTAssertEqual(paymentMethod.type, "ideal")
        XCTAssertEqual(paymentMethod.name, "iDEAL")
        XCTAssertEqual(paymentMethod.details.count, 1)
        XCTAssertEqual(paymentMethod.details[0].key, "idealIssuer")
        XCTAssertFalse(paymentMethod.details[0].isOptional)
        XCTAssertEqual(paymentMethod.details[0].selectItems.count, 13)
        XCTAssertEqual(paymentMethod.details[0].selectItems[0].identifier, "1121")
        XCTAssertEqual(paymentMethod.details[0].selectItems[0].name, "Test Issuer")
        XCTAssertEqual(paymentMethod.details[0].selectItems[1].identifier, "1154")
        XCTAssertEqual(paymentMethod.details[0].selectItems[1].name, "Test Issuer 5")
        XCTAssertEqual(paymentMethod.paymentMethodData, "Hee57361f99ddcf4!ZW5jcnlwdGVkPUJRQUJBZ0FkMDkxS08yQW5CN3U0MyUyQkZLQ1lDSGhUdFo3MXNuTkk4Uk5TdnMlMkZzc0tTMzA0WFFkTlJPWCUyQjd4a2dxRXFkYkY1NkdTRUlVZW9NRlJwc1c1MFp4cmdkdjRWWUlzRlclMkJTZkYzNzR5OERCR2N2JTJGajZOYjJmcSUyRk9OaFVLQzlqYXN5eSUyQm45TWVjRm8xaWd0d3RtUW5BRWxzSGN5a0JVOWdoZDQzM0hnR3NKTDg4ckUxZHVwNDdyYSUyQmtabDJobHpxMzhVbGFTd0ZoNnMzNDZaOEdDTzlFJTJGVjcwR0tMVFdORHZ6Tlk1SlMwQUl5VEUlMkZDJTJCMW1MSUZjTCUyRndrR1NiOHFOSSUyQmFvNGtMbnRoZGNpZmFpbFJ4YWNyMHY5MWZGNHVzYXQwVll2YTV3eUxOT0dxdDI3T2VZSDdvVlZqQlRueWszclhNTU5GZXQ3byUyRjV2TnJESVl2TVA2M1l3JTJCYmxpOVpUVWFMN0pyMlBZWmt6QTN4M2JpalNzdDh4ckdmQXV1a1A4MEhNOTVYcTVTSWJMeWY3T1klMkZuMWNBaHJ1YjZncWlwJTJGT0RRb1RsYURBSFltNDRGUGZoaUxnR2tMJTJGcWE1bXN5cGxVQmwlMkZtZ0UzTHlqV0Qzb1l2Y1RqYk8wYTVidmZWTFlTVUFVTmZBbGpWS3lBeFdNQ0hsaDA5ZjUzN0I1eWtXYTlMWUtoZiUyRlBmcWhBcHRTNFNEcmJOZFdUaFl3dHRUaE4lMkJkemVxRll6N0glMkZPS0Vqc3hGWE14ZWdlcHdOdzFiNmtBdmFjdWsySnh6YjB3QSUyRnVqdUVZc1haR0lXUWtNQm1lT2pGSlloRlkzTWNocm1PaEFKS2dFSklnalJDVktMbnRwaEpMRkxpJTJGcU5tVCUyRk82YWN1WHolMkZ5RnUxdzBvem1ZSFRvcmIzUTVLVmJHZVJEblZ6TnFvS0h2NTNTQVAlMkJ6YW1hSENBRXA3SW10bGVTSTZJa0ZHTUVGQlFURXdNME5CTlRNM1JVRkZSRGczUXpJMFJFUTFNemt3T1VJNE1FRTNPRUU1TWpORk16Z3lNMFEyT0VSQlEwTTVORUk1UmtZNE16QTFSRU1pZmUyT2xTWkJ3bm9DSmgzZU1WU3JEU05pbWkwYVE5bm1sRWRPUGF5ZE81USUzRCZ2ZXJzaW9uPTI=")
    }
    
}

extension PaymentDetail {
    var selectItems: [SelectItem] {
        switch inputType {
        case let .select(selectItems):
            return selectItems
        default:
            return []
        }
    }
    
}
