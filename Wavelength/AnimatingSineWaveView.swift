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

    /** Percent of the view height that the largest bar will occupy */
    var amplitude = CGFloat(0.5)
    /** Number of full sin waves that will occupy the view width */
    var frequency = CGFloat(2)
    /** Number of seconds it takes to get through one full sin wave */
    var speed = CGFloat(2)

    var displayLink: CADisplayLink!
    var animationStarted = false
    var lastDrawTime = CFTimeInterval(0)
    var sinXOffset = CGFloat(0)

    required init(coder aDecoder: NSCoder) {
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
        UIColor.lightGreenColor().set()

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

        CGContextFillRect(ctx, CGRectMake(x, 0, kBarWidth, barHeightPercent * viewRect.height * amplitude))
    }
}
