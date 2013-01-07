//
//  NUIGraphics.m
//  NUIDemo
//
//  Created by Tom Benner on 11/25/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import "NUIGraphics.h"

@implementation NUIGraphics

+ (UIImage*)backButtonWithClass:(NSString*)className
{
    int borderWidth = 1;
    int cornerRadius = 7;
    int width = 50;
    int height = 32;
    int dWidth = width - borderWidth;
    int dHeight = height - borderWidth;
    int arrowWidth = 14;
    
    CAShapeLayer *shape       = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, width, height);
    shape.backgroundColor = [[UIColor clearColor] CGColor];
    shape.fillColor = [[UIColor clearColor] CGColor];
    shape.strokeColor = [[UIColor clearColor] CGColor];
    shape.lineWidth = 0;
    shape.lineCap = kCALineCapRound;
    shape.lineJoin = kCALineJoinRound;
    
    if ([NUISettings hasProperty:@"background-color" withClass:className]) {
        shape.fillColor = [[NUISettings getColor:@"background-color" withClass:className] CGColor];
    }
    if ([NUISettings hasProperty:@"background-color-top" withClass:className]) {
        shape.fillColor = [[NUISettings getColor:@"background-color-top" withClass:className] CGColor];
    }
    
    if ([NUISettings hasProperty:@"border-color" withClass:className]) {
        shape.strokeColor = [[NUISettings getColor:@"border-color" withClass:className] CGColor];
    }
    
    if ([NUISettings hasProperty:@"border-width" withClass:className]) {
        shape.lineWidth = [NUISettings getFloat:@"border-width" withClass:className];
    }
    
    if ([NUISettings hasProperty:@"corner-radius" withClass:className]) {
        cornerRadius = [NUISettings getFloat:@"corner-radius" withClass:className];
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, dWidth, dHeight - cornerRadius);
    CGPathAddArcToPoint(path, NULL, dWidth, dHeight, dWidth - cornerRadius, dHeight, cornerRadius);
    CGPathAddLineToPoint(path, NULL, arrowWidth, dHeight);
    CGPathAddLineToPoint(path, NULL, borderWidth, height/2);
    CGPathAddLineToPoint(path, NULL, arrowWidth, borderWidth);
    CGPathAddLineToPoint(path, NULL, dWidth - cornerRadius, borderWidth);
    CGPathAddArcToPoint(path, NULL, dWidth, borderWidth, dWidth, borderWidth + cornerRadius, cornerRadius);
    CGPathAddLineToPoint(path, NULL, dWidth, dHeight - cornerRadius);
    
    shape.path = path;
    
    UIImage *image = [self caLayerToUIImage:shape];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, arrowWidth + 5, 0, cornerRadius + 5) resizingMode:UIImageResizingModeStretch];
    return image;
}

+ (UIImage*)backButtonWithColor:(UIColor*)color
{
    CIColor *ciColor = [self uiColorToCIColor:color];
    CIImage *ciImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"NUIBackButtonTemplate.png"]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    ciImage = [self tintCIImage:ciImage withColor:ciColor];
    UIImage *uiImage = [UIImage imageWithCGImage:[context createCGImage:ciImage fromRect:ciImage.extent]];
    uiImage = [uiImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 10)];
    
    return uiImage;
}

+ (UIImage*)barButtonWithColor:(UIColor*)color
{
    CIColor *ciColor = [self uiColorToCIColor:color];
    CIImage *ciImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"NUIBarButtonTemplate.png"]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    ciImage = [self tintCIImage:ciImage withColor:ciColor];
    UIImage *uiImage = [UIImage imageWithCGImage:[context createCGImage:ciImage fromRect:ciImage.extent]];
    uiImage = [uiImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    return uiImage;
}

+ (CIColor*)uiColorToCIColor:(UIColor*)color
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return [CIColor colorWithRed:red green:green blue:blue];
}

+ (UIImage*)caLayerToUIImage:(CALayer*)layer
{
    UIGraphicsBeginImageContext(layer.frame.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CALayer*)uiImageToCALayer:(UIImage*)image
{
    CALayer*    layer = [CALayer layer];
    CGFloat nativeWidth = CGImageGetWidth(image.CGImage);
    CGFloat nativeHeight = CGImageGetHeight(image.CGImage);
    CGRect      startFrame = CGRectMake(0.0, 0.0, nativeWidth, nativeHeight);
    layer.contents = (id)image.CGImage;
    layer.frame = startFrame;
    return layer;
}

+ (CIImage*)tintCIImage:(CIImage*)image withColor:(CIColor*)color
{
    CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
    CIImage *baseImage = image;
    
    [monochromeFilter setValue:baseImage forKey:@"inputImage"];        
    [monochromeFilter setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75] forKey:@"inputColor"];
    [monochromeFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];
    
    CIFilter *compositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    
    CIFilter *colorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    [colorGenerator setValue:color forKey:@"inputColor"];
    
    [compositingFilter setValue:[colorGenerator valueForKey:@"outputImage"] forKey:@"inputImage"];
    [compositingFilter setValue:[monochromeFilter valueForKey:@"outputImage"] forKey:@"inputBackgroundImage"];
    
    CIImage *outputImage = [compositingFilter valueForKey:@"outputImage"];
    
    return outputImage;
}

+ (UIImage*)colorImage:(UIColor*)color withFrame:(CGRect)frame
{
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [color setFill];
    UIRectFill(frame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (CAGradientLayer*)gradientLayerWithTop:(id)topColor bottom:(id)bottomColor frame:(CGRect)frame
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = frame;
    layer.colors = [NSArray arrayWithObjects:
                    (id)[topColor CGColor],
                    (id)[bottomColor CGColor], nil];
    layer.startPoint = CGPointMake(0.5f, 0.0f);
    layer.endPoint = CGPointMake(0.5f, 1.0f);
    return layer;
}

+ (UIImage*)gradientImageWithTop:(id)topColor bottom:(id)bottomColor frame:(CGRect)frame
{
    CAGradientLayer *layer = [self gradientLayerWithTop:topColor bottom:bottomColor frame:frame];
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
