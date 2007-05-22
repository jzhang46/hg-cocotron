/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/NSBezierPath.h>
#import <AppKit/KGMutablePath.h>
#import <AppKit/CGContext.h>
#import <AppKit/NSGraphicsContext.h>
#import <Foundation/NSAffineTransform.h>
#import <Foundation/NSRaise.h>

@implementation NSBezierPath

static float           _defaultLineWidth=1.0;
static float           _defaultMiterLimit=10.0;
static float           _defaultFlatness=0.6;
static NSWindingRule   _defaultWindingRule=NSNonZeroWindingRule;
static NSLineCapStyle  _defaultLineCapStyle=NSButtLineCapStyle;
static NSLineJoinStyle _defaultLineJoinStyle=NSMiterLineJoinStyle;

-init {
   _path=[[KGMutablePath alloc] init];
   _lineWidth=_defaultLineWidth;
   _miterLimit=_defaultMiterLimit;
   _flatness=_defaultFlatness;
   _windingRule=_defaultWindingRule;
   _lineCapStyle=_defaultLineCapStyle;
   _lineJoinStyle=_defaultLineJoinStyle;
   _dashCount=0;
   _dashes=NULL;
   _dashPhase=0;
   _cachesPath=NO;
   _lineWidthIsDefault=YES;
   _miterLimitIsDefault=YES;
   _flatnessIsDefault=YES;
   _windingRuleIsDefault=YES;
   _lineCapStyleIsDefault=YES;
   _lineJoinStyleIsDefault=YES;
   return self;
}

-(void)dealloc {
   [_path release];
   if(_dashes!=NULL)
    NSZoneFree(NULL,_dashes);
   [super dealloc];
}

-copyWithZone:(NSZone *)zone {
   NSBezierPath *copy=NSCopyObject(self,0,zone);
   
   copy->_path=[_path mutableCopy];
   if(_dashCount>0){
    int i;
    
    copy->_dashes=NSZoneMalloc(NULL,sizeof(float)*_dashCount);
    for(i=0;i<_dashCount;i++)
     copy->_dashes[i]=_dashes[i];
   }
   
   return copy;
}

+(NSBezierPath *)bezierPath {
   return [[[self alloc] init] autorelease];
}

+(NSBezierPath *)bezierPathWithOvalInRect:(NSRect)rect {
   NSBezierPath *result=[[[self alloc] init] autorelease];
   
   [result appendBezierPathWithOvalInRect:rect];
   
   return result;
}

+(NSBezierPath *)bezierPathWithRect:(NSRect)rect {
   NSBezierPath *result=[[[self alloc] init] autorelease];
   
   [result appendBezierPathWithRect:rect];
   
   return result;
}

+(float)defaultLineWidth {
   return _defaultLineWidth;
}

+(float)defaultMiterLimit {
   return _defaultMiterLimit;
}

+(float)defaultFlatness {
   return _defaultFlatness;
}

+(NSWindingRule)defaultWindingRule {
   return _defaultWindingRule;
}

+(NSLineCapStyle)defaultLineCapStyle {
   return _defaultLineCapStyle;
}

+(NSLineJoinStyle)defaultLineJoinStyle {
   return _defaultLineJoinStyle;
}

+(void)setDefaultLineWidth:(float)width {
   _defaultLineWidth=width;
}

+(void)setDefaultMiterLimit:(float)limit {
   _defaultMiterLimit=limit;
}

+(void)setDefaultFlatness:(float)flatness {
   _defaultFlatness=flatness;
}

+(void)setDefaultWindingRule:(NSWindingRule)rule {
   _defaultWindingRule=rule;
}

+(void)setDefaultLineCapStyle:(NSLineCapStyle)style {
   _defaultLineCapStyle=style;
}

+(void)setDefaultLineJoinStyle:(NSLineJoinStyle)style {
   _defaultLineJoinStyle=style;
}

+(void)fillRect:(NSRect)rect {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextSaveGState(context);
 // set default attributes ?
   CGContextFillRect(context,rect);
   CGContextRestoreGState(context);
}

+(void)strokeRect:(NSRect)rect {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextSaveGState(context);
 // set default attributes ?
   CGContextStrokeRect(context,rect);
   CGContextRestoreGState(context);
}

+(void)strokeLineFromPoint:(NSPoint)point toPoint:(NSPoint)toPoint {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextBeginPath(context);
   CGContextMoveToPoint(context,point.x,point.y);
   CGContextAddLineToPoint(context,toPoint.x,toPoint.y);
   CGContextStrokePath(context);
}

+(void)drawPackedGlyphs:(const char *)packed atPoint:(NSPoint)point {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   CGGlyph   *glyphs;
   unsigned   count=0;

// FIX, unpack glyphs
   CGContextShowGlyphsAtPoint(context,point.x,point.y,glyphs,count);
}

+(void)clipRect:(NSRect)rect {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextClipToRect(context,rect);
}

-(float)lineWidth {
   if(_lineWidthIsDefault)
    return _defaultLineWidth;
   else
    return _lineWidth;
}

-(float)miterLimit {
   if(_miterLimitIsDefault)
    return _defaultMiterLimit;
   else
    return _miterLimit;
}

-(float)flatness {
   if(_flatnessIsDefault)
    return _defaultFlatness;
   else
    return _flatness;
}

-(NSWindingRule)windingRule {
   if(_windingRuleIsDefault)
    return _defaultWindingRule;
   else
    return _windingRule;
}

-(NSLineCapStyle)lineCapStyle {
   if(_lineCapStyleIsDefault)
    return _defaultLineCapStyle;
   else
    return _lineCapStyle;
}

-(NSLineJoinStyle)lineJoinStyle {
   if(_lineJoinStyleIsDefault)
    return _defaultLineJoinStyle;
   else
    return _lineJoinStyle;
}

-(void)getLineDash:(float *)dashes count:(int *)count phase:(float *)phase {
   if(dashes!=NULL){
    int i;
    
    for(i=0;i<_dashCount;i++)
     dashes[i]=_dashes[i];
   }
   if(count!=NULL)
    *count=_dashCount;
   if(phase!=NULL)
    *phase=_dashPhase;
}

-(BOOL)cachesBezierPath {
   return _cachesPath;
}

-(int)elementCount {
   return [_path numberOfOperators];
}

-(NSBezierPathElement)elementAtIndex:(int)index {
   return [_path operators][index];
}

-(NSBezierPathElement)elementAtIndex:(int)index associatedPoints:(NSPoint *)points {
   NSUnimplementedMethod();
}

-(void)setLineWidth:(float)width {
   _lineWidth=width;
   _lineWidthIsDefault=NO;
}

-(void)setMiterLimit:(float)limit {
   _miterLimit=limit;
   _miterLimitIsDefault=NO;
}

-(void)setFlatness:(float)flatness {
   _flatness=flatness;
   _flatnessIsDefault=NO;
}

-(void)setWindingRule:(NSWindingRule)rule {
   _windingRule=rule;
   _windingRuleIsDefault=NO;
}

-(void)setLineCapStyle:(NSLineCapStyle)style {
   _lineCapStyle=style;
   _lineCapStyleIsDefault=NO;
}

-(void)setLineJoinStyle:(NSLineJoinStyle)style {
   _lineJoinStyle=style;
   _lineJoinStyleIsDefault=NO;
}

-(void)setLineDash:(const float *)dashes count:(int)count phase:(float)phase {
   if(_dashes!=NULL)
    NSZoneFree(NULL,_dashes);
    
   _dashCount=count;
   if(_dashCount==0)
    _dashes=NULL;
   else {
    int i;
   
    _dashes=NSZoneMalloc(NULL,sizeof(float)*_dashCount);
    for(i=0;i<_dashCount;i++)
     _dashes[i]=dashes[i];
   }
   
   _dashPhase=phase;
}

-(void)setCachesBezierPath:(BOOL)flag {
   _cachesPath=flag;
}

-(BOOL)isEmpty {
   return [_path isEmpty];
}

-(NSRect)bounds {
   NSUnimplementedMethod();
}

-(NSRect)controlPointBounds {
   return [_path boundingBox];
}

-(BOOL)containsPoint:(NSPoint)point {
   BOOL evenOdd=([self windingRule]==NSEvenOddWindingRule)?YES:NO;
   
   return [_path containsPoint:point evenOdd:evenOdd withTransform:NULL];
}

-(NSPoint)currentPoint {
   return [_path currentPoint];
}

-(void)moveToPoint:(NSPoint)point {
   [_path moveToPoint:point withTransform:NULL];
}

-(void)lineToPoint:(NSPoint)point {
   [_path addLineToPoint:point withTransform:NULL];
}

-(void)curveToPoint:(NSPoint)point controlPoint1:(NSPoint)cp1 controlPoint2:(NSPoint)cp2 {
   [_path addCurveToControlPoint:point controlPoint:cp1 endPoint:cp2 withTransform:NULL];
}

-(void)closePath {
   [_path closeSubpath];
}

-(void)relativeMoveToPoint:(NSPoint)point {
   [_path relativeMoveToPoint:point withTransform:NULL];
}

-(void)relativeLinetoPoint:(NSPoint)point {
   [_path addRelativeLineToPoint:point withTransform:NULL];
}

-(void)relativeCurveToPoint:(NSPoint)point controlPoint1:(NSPoint)cp1 controlPoint2:(NSPoint)cp2 {
   [_path addRelativeCurveToControlPoint:point controlPoint:cp1 endPoint:cp2 withTransform:NULL];
}

-(void)appendBezierPathWithPoints:(NSPoint *)points count:(unsigned)count {
   [_path addLinesWithPoints:points count:count withTransform:NULL];
}

-(void)appendBezierPathWithRect:(NSRect)rect {
   [_path addRect:rect withTransform:NULL];
}

-(void)appendBezierPathWithOvalInRect:(NSRect)rect {
   [_path addEllipseInRect:rect withTransform:NULL];
}

-(void)appendBezierPathWithArcFromPoint:(NSPoint)point toPoint:(NSPoint)toPoint radius:(float)radius {
   [_path addArcToPoint:point point:toPoint radius:radius withTransform:NULL];
}

-(void)appendBezierPathWithArcWithCenter:(NSPoint)center radius:(float)radius startAngle:(float)startAngle endAngle:(float)endAngle {
   [_path addArcAtPoint:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES withTransform:NULL];
}

-(void)appendBezierPathWithArcWithCenter:(NSPoint)center radius:(float)radius startAngle:(float)startAngle endAngle:(float)endAngle clockwise:(BOOL)clockwise {
   [_path addArcAtPoint:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise withTransform:NULL];
}

-(void)appendBezierPathWithGlyph:(NSGlyph)glyph inFont:(NSFont *)font {
   [self appendBezierPathWithGlyphs:&glyph count:1 inFont:font];
}

-(void)appendBezierPathWithGlyphs:(NSGlyph *)glyphs count:(unsigned)count inFont:(NSFont *)font {
   NSUnimplementedMethod();
}

-(void)appendBezierPathWithPackedGlyphs:(const char *)packed {
//   NSGlyph *glyphs;
//   unsigned count=0;
   
// FIX, unpack glyphs
// does this use the current font?
//   [self appendBezierPathWithGlyphs:glyphs count:count inFont:font];
   NSUnimplementedMethod();
}

-(void)appendBezierPath:(NSBezierPath *)other {
   [_path addPath:other->_path withTransform:NULL];
}

-(void)transformUsingAffineTransform:(NSAffineTransform *)matrix {
   NSAffineTransformStruct atStruct=[matrix transformStruct];
   CGAffineTransform       cgMatrix;
   
   cgMatrix.a=atStruct.m11;
   cgMatrix.b=atStruct.m12;
   cgMatrix.c=atStruct.m21;
   cgMatrix.d=atStruct.m22;
   cgMatrix.tx=atStruct.tX;
   cgMatrix.ty=atStruct.tY;
   
   [_path applyTransform:cgMatrix];
}

-(void)removeAllPoints {
   [_path reset];
}

-(void)setAssociatedPoints:(NSPoint *)points atIndex:(int)index {
   NSUnimplementedMethod();
}

-(NSBezierPath *)bezierPathByFlatteningPath {
   NSUnimplementedMethod();
}

-(NSBezierPath *)bezierPathByReversingPath {
   NSUnimplementedMethod();
}


-(void)stroke {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextSaveGState(context);
   
 // set attributes ?
   CGContextBeginPath(context);
   CGContextAddPath(context,_path);
   CGContextStrokePath(context);
   CGContextRestoreGState(context);
}

-(void)fill {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];
   
   CGContextSaveGState(context);
 // set attributes ?
   CGContextBeginPath(context);
   CGContextAddPath(context,_path);
   CGContextFillPath(context);
   CGContextRestoreGState(context);
}


-(void)addClip {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];

	if(CGContextIsPathEmpty(context))
		CGContextBeginPath(context);
   CGContextAddPath(context,_path);
   CGContextClip(context);
}

-(void)setClip {
   KGContext *context=[[NSGraphicsContext currentContext] graphicsPort];

	CGContextBeginPath(context);
   CGContextAddPath(context,_path);
   CGContextClip(context);
}


@end
