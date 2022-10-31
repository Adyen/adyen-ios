//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

enum PostalAddressMocks {
    static let newYorkPostalAddress = PostalAddress(city: "New York",
                                                    country: "US",
                                                    houseNumberOrName: "14",
                                                    postalCode: "10019",
                                                    stateOrProvince: "NY",
                                                    street: "8th Ave",
                                                    apartment: nil)
    static let losAngelesPostalAddress = PostalAddress(city: "Los Angeles",
                                                       country: "US",
                                                       houseNumberOrName: "3310",
                                                       postalCode: "90040",
                                                       stateOrProvince: "CA",
                                                       street: "Garfield Ave",
                                                       apartment: nil)
    
    static let singaporePostalAddress = PostalAddress(city: "Singapore",
                                                      country: "Singapore",
                                                      houseNumberOrName: "109",
                                                      postalCode: "179097",
                                                      stateOrProvince: "North East Community",
                                                      street: "North Bridge Rd, #10-22 Funan",
                                                      apartment: nil)
    
    static let emptyUSPostalAddress = PostalAddress(city: "",
                                                    country: "US",
                                                    houseNumberOrName: "",
                                                    postalCode: "",
                                                    stateOrProvince: "AL",
                                                    street: "",
                                                    apartment: nil)
}
