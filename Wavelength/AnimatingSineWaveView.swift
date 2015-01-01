//
//  AnimatingSineWaveView.swift
//  Wavelength
//
//  Created by Rajeev Nayak on 12/27/14.
//  Copyright (c) 2014 jeev. All rights reserved.
//

class AnimatingSineWaveView: UIView {

    let kBarSpacing = CGFloat(5)
    let kBarWidth = CGFloat(13)
    let kWavelength = 2 * CGFloat(M_PI)

    let kDefaultMinBarHeight = CGFloat(0)
    let kDefaultAmplitude = CGFloat(0.5)
    let kDefaultFrequency = CGFloat(2)
    let kDefaultSpeed = CGFloat(2)
    let kDefaultColor = UIColor.lightGreenColor()

    /** Percent of the view height that the smallest bar will occupy */
    var minBarHeight: CGFloat
    /** Percent of the view height that the sine wave occupies. This means the largest bar's height will be (minBarHeight + amplitude) * view.height */
    var amplitude: CGFloat
    /** Number of full sin waves that will occupy the view width */
    var frequency: CGFloat
    /** Number of seconds it takes to get through one full sin wave */
    var speed: CGFloat
    /** Color of the animating bars */
    var color: UIColor

    var transformationStartTime: CFTimeInterval?
    var transformationTimeCheckpoints: [CFTimeInterval]?
    var transformationMinBarHeightCheckpoints: [CGFloat]?
    var transformationAmplitudeCheckpoints: [CGFloat]?
    var transformationFrequencyCheckpoints: [CGFloat]?
    var transformationSpeedCheckpoints: [CGFloat]?
    var transformationColorCheckpoints: [UIColor]?

    var displayLink: CADisplayLink!
    var animationStarted = false
    var lastDrawTime = CFTimeInterval(0)
    var sinXOffset = CGFloat(0)

    required init(coder aDecoder: NSCoder) {
        minBarHeight = kDefaultMinBarHeight
        amplitude = kDefaultAmplitude
        frequency = kDefaultFrequency
        speed = kDefaultSpeed
        color = kDefaultColor

        super.init(coder: aDecoder)

        backgroundColor = UIColor.clearColor()
        displayLink = CADisplayLink(target: self, selector: "setNeedsDisplay")
    }

    override func drawRect(rect: CGRect) {
        if !animationStarted {
            displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            animationStarted = true
            return
        }

        interpolateTransformationPropertiesIfNecessary()

        if lastDrawTime == 0 {
            lastDrawTime = displayLink.timestamp
        } else {
            // modify the x offset to move the sine wave based on the current speed
            let elapsedTime = displayLink.timestamp - lastDrawTime
            sinXOffset -= (CGFloat(elapsedTime) / speed) * kWavelength
            if sinXOffset < -kWavelength {
                sinXOffset += kWavelength
            }
        }

        let middle = rect.width / 2
        let ctx = UIGraphicsGetCurrentContext()
        color.set()

        // draw the left half bars from left to right
        var x = kBarSpacing
        while x <= middle - 2 * (kBarWidth + kBarSpacing) {
            drawBarAt(x, inViewWithRect: rect, withContext: ctx)
            x += (kBarWidth + kBarSpacing)
        }

        // draw the right half bars from left to right
        x = rect.width - kBarSpacing - kBarWidth
        while x >= middle + 1 * (kBarWidth + kBarSpacing) {
            drawBarAt(x, inViewWithRect: rect, withContext: ctx)
            x -= (kBarWidth + kBarSpacing)
        }

        lastDrawTime = displayLink.timestamp
    }

    func drawBarAt(x: CGFloat, inViewWithRect viewRect: CGRect, withContext ctx: CGContext!) {
        // get the x-coordinate at the middle of the bar
        let barMiddle = x + kBarWidth / 2
        // adjust the x-coordinate based on the frequency so that it can be passed into the sin function
        // (since we want [frequency] waves to fit in the width, we multiply by [frequency] wavelengths and divide by the width)
        let frequencyAdjustedX = barMiddle * frequency * kWavelength / viewRect.width
        // compute the percentage of the height that this bar should occupy (adjust our x by the offset,
        // then add 1 and divide by two to transform the sin function output range from [-1, 1] to [0, 1])
        let barHeightPercent = (sin(frequencyAdjustedX + sinXOffset) + 1) / 2

        CGContextFillRect(ctx, CGRectMake(x, 0, kBarWidth, (minBarHeight + barHeightPercent * amplitude) * viewRect.height))
    }

    func transformSineWaveWithTimeCheckpoints(timeCheckpoints: [CFTimeInterval], minBarHeightCheckpoints: [CGFloat]?, amplitudeCheckpoints: [CGFloat]?, frequencyCheckpoints: [CGFloat]?, speedCheckpoints: [CGFloat]?, colorCheckpoints: [UIColor]?) {
        transformationStartTime = displayLink.timestamp
        transformationTimeCheckpoints = [CFTimeInterval(0)] + timeCheckpoints
        if let minBarHeightCheckpoints = minBarHeightCheckpoints {
            transformationMinBarHeightCheckpoints = [minBarHeight] + minBarHeightCheckpoints
        } else {
            transformationMinBarHeightCheckpoints = nil
        }
        if let amplitudeCheckpoints = amplitudeCheckpoints {
            transformationAmplitudeCheckpoints = [amplitude] + amplitudeCheckpoints
        } else {
            transformationAmplitudeCheckpoints = nil
        }
        if let frequencyCheckpoints = frequencyCheckpoints {
            transformationFrequencyCheckpoints = [frequency] + frequencyCheckpoints
        } else {
            transformationFrequencyCheckpoints = nil
        }
        if let speedCheckpoints = speedCheckpoints {
            transformationSpeedCheckpoints = [speed] + speedCheckpoints
        } else {
            transformationSpeedCheckpoints = nil
        }
        if let colorCheckpoints = colorCheckpoints {
            transformationColorCheckpoints = [color] + colorCheckpoints
        } else {
            transformationColorCheckpoints = nil
        }
    }

    func interpolateTransformationPropertiesIfNecessary() {
        if transformationStartTime == nil {
            return
        }

        let transformationElapsedTime = displayLink.timestamp - transformationStartTime!
        var prevTimeCheckpoint = CFTimeInterval(0)
        var prevCheckpointIndex = 0
        var nextTimeCheckpoint: CFTimeInterval?
        var nextCheckpointIndex: Int?
        for (i, timeCheckpoint) in enumerate(transformationTimeCheckpoints!) {
            if timeCheckpoint < transformationElapsedTime {
                prevTimeCheckpoint = timeCheckpoint
                prevCheckpointIndex = i
            } else {
                nextTimeCheckpoint = timeCheckpoint
                nextCheckpointIndex = i
                break
            }
        }

        if let nextTimeCheckpoint = nextTimeCheckpoint {
            let fraction = CGFloat(transformationElapsedTime - prevTimeCheckpoint) / CGFloat(nextTimeCheckpoint - prevTimeCheckpoint)
            if let minBarHeightCheckpoints = transformationMinBarHeightCheckpoints {
                minBarHeight = interpolateFloatBetween(minBarHeightCheckpoints[prevCheckpointIndex], and: minBarHeightCheckpoints[nextCheckpointIndex!], withFraction: fraction)
            }
            if let amplitudeCheckpoints = transformationAmplitudeCheckpoints {
                amplitude = interpolateFloatBetween(amplitudeCheckpoints[prevCheckpointIndex], and: amplitudeCheckpoints[nextCheckpointIndex!], withFraction: fraction)
            }
            if let frequencyCheckpoints = transformationFrequencyCheckpoints {
                frequency = interpolateFloatBetween(frequencyCheckpoints[prevCheckpointIndex], and: frequencyCheckpoints[nextCheckpointIndex!], withFraction: fraction)
            }
            if let speedCheckpoints = transformationSpeedCheckpoints {
                speed = interpolateFloatBetween(speedCheckpoints[prevCheckpointIndex], and: speedCheckpoints[nextCheckpointIndex!], withFraction: fraction)
            }
            if let colorCheckpoints = transformationColorCheckpoints {
                color = interpolateColorBetween(colorCheckpoints[prevCheckpointIndex], and: colorCheckpoints[nextCheckpointIndex!], withFraction: fraction)
            }
        } else {
            if let minBarHeightCheckpoints = transformationMinBarHeightCheckpoints {
                minBarHeight = minBarHeightCheckpoints.last!
            }
            if let amplitudeCheckpoints = transformationAmplitudeCheckpoints {
                amplitude = amplitudeCheckpoints.last!
            }
            if let frequencyCheckpoints = transformationFrequencyCheckpoints {
                frequency = frequencyCheckpoints.last!
            }
            if let speedCheckpoints = transformationSpeedCheckpoints {
                speed = speedCheckpoints.last!
            }
            if let colorCheckpoints = transformationColorCheckpoints {
                color = colorCheckpoints.last!
            }

            transformationStartTime = nil
        }
    }

    func interpolateFloatBetween(start: CGFloat, and end: CGFloat, withFraction fraction: CGFloat) -> CGFloat {
        if fraction < 0.5 {
            return 2 * fraction * fraction * (end - start) + start
        } else {
            return (2 * fraction * fraction - 4 * fraction + 1) * (start - end) + start
        }
    }

    func interpolateColorBetween(start: UIColor, and end: UIColor, withFraction fraction: CGFloat) -> UIColor {
        let startComponents = CGColorGetComponents(start.CGColor)
        let endComponents = CGColorGetComponents(end.CGColor)
        let red = interpolateFloatBetween(startComponents[0], and: endComponents[0], withFraction: fraction)
        let green = interpolateFloatBetween(startComponents[1], and: endComponents[1], withFraction: fraction)
        let blue = interpolateFloatBetween(startComponents[2], and: endComponents[2], withFraction: fraction)
        let alpha = interpolateFloatBetween(startComponents[3], and: endComponents[3], withFraction: fraction)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
