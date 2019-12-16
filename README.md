#  Payments Example

This project illustrates the use of [this library](https://github.com/neilsmithdesign/Payments) for handling StoreKit transactions. Specifically, local receipt validation. 

A lot of my own knowledge was gained from [this excellent series of blog posts](https://www.andrewcbancroft.com/2017/08/01/local-receipt-validation-swift-start-finish/) from [Andrew Bancroft](https://twitter.com/andrewcbancroft).

## Disclaimer

This implementation does not guarantee your app will be immune from attacks to circumvent your receipt validation logic. Always take concerted steps to obfuscate your code when validating receipts locally. The example is for learning purposes only. 
