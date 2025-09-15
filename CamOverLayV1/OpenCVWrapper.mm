//
//  OpenCVWrapper.m
//  CamOverLayV1
//
//  Created by Thiruvasagam Thirunavukkarasu on 9/15/25.
//

#import "OpenCVWrapper.h"

#import <opencv2/opencv.hpp>


@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}


@end
