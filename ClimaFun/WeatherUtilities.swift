//
//  WeatherUtilities.swift
//  ClimaFun
//
//  Created by Itamar Biton on 29/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

class WeatherUtilities {
    struct UserDefaultsKeys {
        static let shouldUseFahrenheit = "com.itamarbiton.ClimaFun.shouldUseFahrenheit"
    }
    
    /**
     Returns the unit sign that matches the selected unit system
     
     - Returns: A string containing either "F" for Fahrenheit or "C" for Celsuis
     */
    static func selectedUnitSign() -> String {
        // get the selected unit state
        let isFahrenheitSelected = UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldUseFahrenheit)
        
        // return the appropriate sign
        if (isFahrenheitSelected) { return "°F" } else { return "°C" }
    }
    
    /**
     Tells whether the app should use the Fahrenheit unit system or not
     
     - Returns: true if Fahrenheit should be used, false if not
     */
    static func shouldUseFahrenheit() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldUseFahrenheit)
    }

    /**
     Sets the selected unit system
     
     - Parameter isFahrenheit: Sets whether the app should use the Fahrenheit unit system
     */
    static func setSelectedUnit(isFahrenheit: Bool) {
        // set the selected unit
        UserDefaults.standard.set(isFahrenheit, forKey: UserDefaultsKeys.shouldUseFahrenheit)
    }
    
    /**
     Converts the received temperature value to the selected unit system
     
     - Parameter temperatureInCelsius: The temperature value that should be converted in Celsius
     - Returns: The received temperature in the selected unit system (either Celsius or Fahrenheit)
     */
    static func convertToSelectedUnit(temperatureInCelsius: Float) -> Float {
        if (shouldUseFahrenheit()) {
            return temperatureInCelsius * (9/5) + 32
        } else {
            return temperatureInCelsius
        }
    }
    
    /**
     Returns a string that describes the received temperature forecast value.
     
     - Parameter tempValue: A ForecastValue used to create the temperature string.
     - Returns: A string that describes the minimum and maximum temperature separated by '~'.
     */
    static func stringForTemperature(tempValue: ForecastValue) -> String {
        // get the selected unit sign
        let sign = WeatherUtilities.selectedUnitSign()
        
        // calculate the temperature using the selected unit
        var tempMin = 0
        if let tempMinCelsius = tempValue.min {
            tempMin = Int(WeatherUtilities.convertToSelectedUnit(temperatureInCelsius: tempMinCelsius))
        }
        var tempMax = 0
        if let tempMaxCelsius = tempValue.max {
            tempMax = Int(WeatherUtilities.convertToSelectedUnit(temperatureInCelsius: tempMaxCelsius))
        }
        
        return "\(tempMin)\(sign)~\(tempMax)\(sign)"
    }
    
    /**
     Returns a string that describes the received precipitation forecast value.
     
     - Parameter pcpnValue: The precipitation value used to create the string.
     - Parameter addUnit: Sets whether a unit string should be appended at the end of the returned string.
     - Returns: A string the describes the received precipitation value, either followed by a unit string or not.
     */
    static func stringForPcpn(pcpnValue: ForecastValue, addUnit: Bool) -> String {
        // get the max precipitation value
        let pcpnMax = Int(pcpnValue.max ?? 0)
        
        if (addUnit) { return "\(pcpnMax)mm/hr" } else { return "\(pcpnMax)" }
    }
}
