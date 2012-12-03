//
//  GradientView.m
//  iGrow
//
//  Created by Andrew Molloy on 5/15/09.
//  Copyright 2011 Andy Molloy. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

static CGImageRef sNoiseImage = nil;
static CGFloat sNoiseImageWidth = 0;
static CGFloat sNoiseImageHeight = 0;

-(void)drawRect:(CGRect)rect
{
	if ((nil != self.topColor) &&
		(nil != self.bottomColor))
	{
		CGColorRef colors[] = { self.topColor.CGColor, self.bottomColor.CGColor };
		
		CFArrayRef gradientColors = CFArrayCreate( kCFAllocatorDefault,
												  (const void**)&colors,
												  2,
												  &kCFTypeArrayCallBacks );
		CGGradientRef gradient = CGGradientCreateWithColors(NULL,
															gradientColors,
															NULL);
		CFRelease( gradientColors );
		
		if (self.sideways)
		{
			CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
										gradient,
										CGPointMake( 0, 0 ),
										CGPointMake( self.frame.size.width, 0 ),
										0);
		}
		else
		{
			CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
										gradient,
										CGPointMake( 0, 0 ),
										CGPointMake( 0, self.frame.size.height ),
										0);
		}
		
		CFRelease( gradient );
	}
	
	if (NSClassFromString(@"CIFilter"))
	{
		CIFilter* randomGenerator = [CIFilter filterWithName:@"CIRandomGenerator"];
		if (randomGenerator)
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				CIContext* noiseContext = [CIContext contextWithOptions:nil];
				
				CIFilter* noiseGenerator = [CIFilter filterWithName:@"CIColorMonochrome"];
				[noiseGenerator setValue:[randomGenerator valueForKey:@"outputImage"] forKey:@"inputImage"];
				[noiseGenerator setDefaults];
				
				CIImage* ciImage = [noiseGenerator outputImage];
				
				CGRect extentRect = [ciImage extent];
				if (CGRectIsInfinite(extentRect) || CGRectIsEmpty(extentRect))
				{
					extentRect = CGRectMake(0, 0, 64, 64);
				}
				
				sNoiseImage = [noiseContext createCGImage:ciImage fromRect:extentRect];
				sNoiseImageWidth = CGImageGetWidth(sNoiseImage);
				sNoiseImageHeight = CGImageGetHeight(sNoiseImage);
			});
			
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			CGContextSaveGState(ctx);
			CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
			CGContextSetAlpha(ctx, 0.1f);
			CGContextDrawTiledImage(ctx, CGRectMake(0, 0, sNoiseImageWidth, sNoiseImageHeight), sNoiseImage);
			CGContextRestoreGState(ctx);
		}
	}
}


@end
