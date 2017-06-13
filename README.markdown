# Inception with CoreML

This is the **Inception-v3** neural network running on the shiny new CoreML framework. It uses **Inceptionv3.mlmodel** from [Apple's developer website](http://developer.apple.com/machine-learning/).

It runs from a live video feed and performs a prediction 10 times per second. If your device is too slow for this, change the `setUpCamera()` method in **ViewController.swift** to do `videoCapture.fps = 5`.

To use this app, open **Inception.xcodeproj** in Xcode 9 and run it on a device with iOS 11.

![Screenshot](Screenshot.png)
