// Created by Daniele Margutti on 28/06/2019.
// Copyright (c) 2019 Daniele Margutti. All rights reserved
// Original work by https://mourner.github.io/simplify-js/
// Modified by Sergey Ilyin

import UIKit

import CoreLocation

public protocol Point2DRepresentable
{
      var xValue: Double { get }
      var yValue: Double { get }

      var cgPoint: CGPoint { get }

      func distanceFrom( _ otherPoint: Self ) -> Double
      func distanceToSegment( _ p1: Self, _ p2: Self ) -> Double
      func equalsTo( _ compareWith: Self ) -> Bool
}

public extension Point2DRepresentable
{
      var cgPoint: CGPoint { return CGPoint( x: self.xValue, y: self.yValue ) }

      // TODO: describe this!
      func equalsTo( _ compareWith: Self ) -> Bool
      {
            return self.xValue == compareWith.xValue && self.yValue == compareWith.yValue
      }

      // TODO: describe this!
      func distanceFrom( _ otherPoint: Self ) -> Double
      {
            let dx = self.xValue - otherPoint.xValue
            let dy = self.yValue - otherPoint.yValue
            return ( dx * dx ) + ( dy * dy )
      }

      // TODO: describe this!
      func distanceToSegment( _ p1: Self, _ p2: Self ) -> Double
      {
            var x = p1.xValue
            var y = p1.yValue
            var dx = p2.xValue - x
            var dy = p2.yValue - y

            if dx != 0 || dy != 0
            {
                  let t = ( ( xValue - x ) * dx + ( yValue - y ) * dy ) / ( dx * dx + dy * dy )
                  if t > 1
                  {
                        x = p2.xValue
                        y = p2.yValue
                  }
                  else if t > 0
                  {
                        x += dx * t
                        y += dy * t
                  }
            }

            dx = xValue - x
            dy = yValue - y

            return dx * dx + dy * dy
      }
}

extension CLLocationCoordinate2D: Point2DRepresentable
{
      public var xValue: Double { return Double( self.latitude ) }
      public var yValue: Double { return Double( self.longitude ) }
}

extension CGPoint: Point2DRepresentable
{
      public var xValue: Double { return Double( self.x ) }
      public var yValue: Double { return Double( self.y ) }
}
