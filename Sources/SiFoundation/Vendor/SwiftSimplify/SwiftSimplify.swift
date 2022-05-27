// Created by Daniele Margutti on 28/06/2019.
// Copyright (c) 2019 Daniele Margutti. All rights reserved
// Original work by https://mourner.github.io/simplify-js/
// Modified by Sergey Ilyin

import Foundation

// MARK: - SwiftSimplify

public enum SwiftSimplify
{
      // TODO: describe this!
      public static func simplify<P: Point2DRepresentable>( _ points: [ P ], tolerance: Double?, highestQuality: Bool = false ) -> [ P ]
      {
            guard points.count > 1
            else { return points }

            let sqTolerance = ( tolerance != nil ) ? ( tolerance! * tolerance! ) : 1.0
            var result = highestQuality ? points : simplifyRadialDistance( points, tolerance: sqTolerance )
            result = simplifyDouglasPeucker( result, sqTolerance: sqTolerance )

            return result
      }

      // TODO: describe this!
      private static func simplifyRadialDistance<P: Point2DRepresentable>( _ points: [ P ], tolerance: Double ) -> [ P ]
      {
            guard points.count > 2
            else
            {
                  return points
            }

            var prevPoint = points.first!
            var newPoints = [ prevPoint ]
            var currentPoint: P!

            for i in 1 ..< points.count
            {
                  currentPoint = points[ i ]
                  if currentPoint.distanceFrom( prevPoint ) > tolerance
                  {
                        newPoints.append( currentPoint )
                        prevPoint = currentPoint
                  }
            }

            if prevPoint.equalsTo( currentPoint ) == false
            {
                  newPoints.append( currentPoint )
            }

            return newPoints
      }

      // TODO: describe this!
      private static func simplifyDPStep<P: Point2DRepresentable>( _ points: [ P ], first: Int, last: Int, sqTolerance: Double, simplified: inout [ P ] )
      {
            guard last > first
            else
            {
                  return
            }
            var maxSqDistance = sqTolerance
            var index = 0

            for _currentIndex in first + 1 ..< last
            {
                  let sqDistance = points[ _currentIndex ].distanceToSegment( points[ first ], points[ last ] )
                  if sqDistance > maxSqDistance
                  {
                        maxSqDistance = sqDistance
                        index = _currentIndex
                  }
            }

            if maxSqDistance > sqTolerance
            {
                  if ( index - first ) > 1
                  {
                        simplifyDPStep( points, first: first, last: index, sqTolerance: sqTolerance, simplified: &simplified )
                  }
                  simplified.append( points[ index ] )
                  if ( last - index ) > 1
                  {
                        simplifyDPStep( points, first: index, last: last, sqTolerance: sqTolerance, simplified: &simplified )
                  }
            }
      }

      // TODO: describe this!
      private static func simplifyDouglasPeucker<P: Point2DRepresentable>( _ points: [ P ], sqTolerance: Double ) -> [ P ]
      {
            guard points.count > 1
            else
            {
                  return []
            }

            let last = ( points.count - 1 )
            var simplied = [ points.first! ]
            simplifyDPStep( points, first: 0, last: last, sqTolerance: sqTolerance, simplified: &simplied )
            simplied.append( points.last! )

            return simplied
      }
}

// MARK: - ARRAY EXTENSION

public extension Array where Element: Point2DRepresentable
{
      // TODO: describe this!
      func simplify( tolerance: Double? = nil, highestQuality: Bool = true ) -> [ Element ]
      {
            return SwiftSimplify.simplify( self, tolerance: tolerance, highestQuality: highestQuality )
      }
}
