//
//  OpenCVWrapper.m
//  CamOverLayV1
//
//  Created by Thiruvasagam Thirunavukkarasu on 9/15/25.
//
#import <opencv2/opencv.hpp>


#import "OpenCVWrapper.h"

#ifdef NO
#undef NO
#endif
#ifdef YES
#undef YES
#endif






@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}


@end
