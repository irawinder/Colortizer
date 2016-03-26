// Utility method for returning a rectilinear, version of a perspective image 
// given the warped perspective image and 4 points that describe the corners of the 
//
// REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:
// -
// -
// -
// -

// Libraries for 2D image warping/distortion
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

Point[] canonicalPoints = new Point[4];
MatOfPoint2f canonicalMarker;  // create a matrix of square-shape corner points

PImage scanWarp(OpenCV opencv, PVector[] inputPoints, int w, int h) {
  
  PImage warp;
  warp = createImage(w, h, ARGB);  // defines size and format for PImage card manipulated
  opencv.toPImage(warpPerspective(inputPoints, w, h), warp);  // loads onto card an unwarped image
  return warp;
  
}

Mat getPerspectiveTransformation(PVector[] inputPoints, int w, int h)
{    // assists warpPerspective()
  
  canonicalPoints[0].x = w;
  canonicalPoints[0].y = 0;
  
  canonicalPoints[1].x = 0;
  canonicalPoints[1].y = 0;
  
  canonicalPoints[2].x = 0;
  canonicalPoints[2].y = h;
  
  canonicalPoints[3].x = w;
  canonicalPoints[3].y = h;

  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints[i].x, inputPoints[i].y);  // obtain the four user-defined corners of the captured region (from inputPoints)
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);  // create a matrix of corner points from the user-defined area
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);  // camcv function calculating a perspective transform
}

Mat warpPerspective(PVector[] inputPoints, int w, int h)
{    // unwarps nonrectangular shapes
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);  // calls the above method
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));  // creates the final, unwarped image, saves to unWarpedMarker
  return unWarpedMarker;
}
