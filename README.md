
# Cybersource Flex iOS - SDK  

This SDK allows mobile developers to provide credit card payment functionality within their iOS applications, without having to pass sensitive card data back to their application backend servers.  For more information on including payments in your mobile application see our [InApp Payments Guide](TBD)   
   
## SDK Installation 

### Swift Package Manager (Recommended)

#### Using Xcode
1. In Xcode, select **File > Add Package Dependencies**
2. Add the package repository URL or local package path
3. Select your project target 
4. Add **FlexAPIiOSSDK** product to your target

#### Using Package.swift
Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/CyberSource/flex-api-ios-sdk-spm.git", from: "1.0.0")
]
```

Then import the SDK in your Swift files:
```swift
import FlexAPIiOSSDK
```

### CocoaPods (Legacy)
```
    pod 'flex-api-ios-sdk'  
```  

### Manual Installation

For manual framework installation, include the ```FlexAPIiOSSDK.framework``` in the application. In Xcode, select the main project file for the target. In the "General" section of the project's properties, scroll down to "Frameworks, Libraries, and Embedded Content", press the plus sign (+), and select the framework. 

## SDK Usage

### Architecture Overview

#### Backend Responsibilities
Your backend server must:
1. Store merchant credentials securely (merchantId, merchantKey, merchantSecret)
2. Generate capture context by calling CyberSource API with HTTP Signature Authentication
3. Return capture context JWT to your iOS application
4. Process payments using the transient token received from the iOS app

#### iOS App Responsibilities  
Your iOS application will:
1. Request capture context from your backend
2. Collect card information from the user
3. Use this SDK to generate a transient token
4. Send the transient token to your backend for payment processing

### Create capture context (Backend)
Your backend server needs to create a capture context by calling the CyberSource API endpoint with proper authentication. The capture context is a JWT that contains the configuration for tokenization.

**Important**: The capture context must be generated server-side to keep merchant credentials secure. Never expose merchant credentials in your iOS application.

For capture context generation, refer to [HTTP Signature Authentication](https://developer.cybersource.com/api/developer-guides/dita-gettingstarted/authentication/GenerateHeader/httpSignatureAuthentication.html)

### Initialize the SDK and create transient token using capture context
```swift
import FlexAPIiOSSDK

let service = FlexService()

// captureContext is the JWT string received from your backend
let captureContext = "eyJraWQiOiJ6dSIsImFsZyI6IlJTMjU2In0..." // JWT from your backend

service.createTransientToken(from: captureContext, data: getPayload()) { result in
    DispatchQueue.main.async {
        switch result {
        case .success(let transientToken):
            // The transient token is wrapped in a response object
            // Extract the JWT string if needed
            if let tokenString = transientToken.token {
                // Send tokenString to your backend for payment processing
                print("Token generated: \(tokenString)")
            }
        case .failure(let error):
            // Handle error - check error.responseStatus for details
            print("Error: \(error.responseStatus.message)")
        }
    }
```
### Create payload
```swift
private func getPayload() -> [String: String] {
    // All values must be strings, even numeric values
    var payload = [String: String]()
    payload["paymentInformation.card.number"] = "4111111111111111"
    payload["paymentInformation.card.securityCode"] = "123"
    payload["paymentInformation.card.expirationMonth"] = "12"  // String, not Int
    payload["paymentInformation.card.expirationYear"] = "2029" // 4-digit year as String
    return payload
}
```

**Important Notes:**
- All payload values must be strings, including month and year
- Use 4-digit years (e.g., "2029" not "29")
- The payload type must be `[String: String]`
### Using the Transient Token to Create a Transaction Request (Backend)
Your backend server constructs a transaction request using the [Cybersource API](https://developer.cybersource.com/api-reference-assets/index.html#payments_payments_process-a-payment_samplerequests-dropdown_payment-with-flex-token).

**Note**: The transient token may be returned as a JSON object from the SDK. Extract just the JWT string value before sending to CyberSource.

```json
{
  "clientReferenceInformation": {
    "code": "TC50171_3"
  },
  "orderInformation": {
    "amountDetails": {
      "totalAmount": "102.21",
      "currency": "USD"
    },
    "billTo": {
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@example.com",
      "address1": "123 Main Street",
      "locality": "San Francisco",
      "administrativeArea": "CA",
      "postalCode": "94105",
      "country": "US"
    }
  },
  "tokenInformation": {
    "transientTokenJwt": "eyJraWQiOiIwN0JwSE9abkhJM3c3UVAycmhNZkhuWE9XQlhwa1ZHTiIsImFsZyI6IlJTMjU2In0..."
  }
}
```

**Important**: The payment endpoint requires billing information. Ensure your backend includes all required fields for successful payment processing.
```
## Sample Application
We have a sample application which demonstrates the SDK usage:  
[Sample App](https://github.com/CyberSource/flex-v2-ios-sample) 
