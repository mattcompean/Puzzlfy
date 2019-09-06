//
//  JigsawPuzzleEngine.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlePiece.h"

#import "JigsawPuzzleEngine.h"
#import "DBManager.h"
#import "Constants.h"

@interface Shape : NSObject
@property NSInteger left;
@property NSInteger top;
@property NSInteger right;
@property NSInteger bottom;
@end

@implementation Shape

@end

@implementation JigsawPuzzleEngine {
    CGImageRef strokedImage;
    
    CGFloat imageWidth;
    CGFloat imageHeight;
    
    CGFloat tileWidth;
    CGFloat tileHeight;
    CGFloat tileRatio;
    
    NSMutableArray *shapes;
    NSMutableArray *puzzlePieces;
    NSMutableArray *images;
}

- (JigsawPuzzleEngine *) initWithImage:(CGImageRef)puzzleImage withDifficultyValue:(NSInteger) difficultyValue withX:(NSInteger) tilesX andY: (NSInteger) tilesY {
    self.backGroundAlpha = PUZZLE_BACKGROUND_ALPHA;
    _difficultyValue = difficultyValue;
    _puzzleImage = puzzleImage;
    _tilesX = tilesX;
    _tilesY = tilesY;
    
    puzzlePieces = [[NSMutableArray alloc] initWithCapacity:self.tilesX * self.tilesY];
    for (int i = 0; i < self.tilesX * self.tilesY; i++) {
        PuzzlePiece *piece = [PuzzlePiece new];
        puzzlePieces[i] = piece;
        
        piece.locationX = i % self.tilesX;
        piece.locationY = i / self.tilesX;
    }
    
    images = [[NSMutableArray alloc] init];
    
    strokedImage = nil;
    [self computeRandomShapes];
    
    imageWidth = CGImageGetWidth(_puzzleImage);
    imageHeight = CGImageGetHeight(_puzzleImage);
    
    tileWidth = imageWidth / self.tilesX;
    tileHeight = imageHeight / self.tilesY;
    tileRatio = tileWidth / 100.0;
    _pieceWidth = tileWidth;
    
    return self;
}

- (void)dealloc {
    if (strokedImage) {
        CGImageRelease(strokedImage);
    }
    
    puzzlePieces = nil;
    shapes = nil;
//    for (PuzzlePiece *piece in puzzlePieces) {
//        [piece finalize];
//    }
    
    for (NSValue *value in images) {
        CGImageRelease([value pointerValue]);
    }
    images = nil;
}

- (PuzzlePiece *) puzzlePieceAtX:(NSInteger) x andY:(NSInteger) y {
    NSInteger index = y * self.tilesX + x;
    PuzzlePiece *piece = puzzlePieces[index];
    
    if (piece.image == NULL) {
        CGMutablePathRef path;
        
        if(_difficultyValue == DIFFICULTY_SUPER_EASY)
        {
            path = [self createSquareMaskAtX:x andY:y];
        } else {
            Shape *shape = shapes[y * self.tilesX + x];
            path = [self createMaskWithTopTap:shape.top rightTab:shape.right bottomTab:shape.bottom leftTab:shape.left
                                                           atX:tileWidth * x andY:tileWidth * y];
        }
        
        // Draw small image.
        CGRect rect = CGPathGetBoundingBox(path);
        CGRect pieceRect = CGRectMake(rect.origin.x, imageHeight - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
        
        CGImageRef pieceImage = CGImageCreateWithImageInRect(_puzzleImage, pieceRect);
        
        CGContextRef context = [self createPieceContextWithWidth:rect.size.width andHeight:rect.size.height];
        CGContextSetShouldAntialias(context, TRUE);
        
        CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(pieceImage), CGImageGetHeight(pieceImage)), pieceImage);
        
        piece.image = CGBitmapContextCreateImage(context);
        piece.fullSize = rect.size;
        piece.origin = pieceRect.origin;
        
        CGPathRelease(path);
        CGContextRelease(context);
        CGImageRelease(pieceImage);
    }
    
    return piece;
}


- (CGImageRef) aliasedImageForPieceAtX:(NSInteger) x andY:(NSInteger) y {
    return [self puzzleImageAtX:x andY:y antiAlieased:NO];
}

- (PuzzlePiece *) puzzlePieceAtIndex:(NSInteger) index {
    return [self puzzlePieceAtX:index % self.tilesX andY:index / self.tilesX];
}

- (CGImageRef) puzzleImageAtX:(NSInteger) x andY:(NSInteger) y antiAlieased:(BOOL) aa {
    CGImageRef image = NULL;
    
    if (image == NULL) {
        CGMutablePathRef path;
        
        if(_difficultyValue == DIFFICULTY_SUPER_EASY)
        {
            path = [self createSquareMaskAtX:x andY:y];
        } else {
            Shape *shape = shapes[y * self.tilesX + x];
            path = [self createMaskWithTopTap:shape.top rightTab:shape.right bottomTab:shape.bottom leftTab:shape.left
                                          atX:tileWidth * x andY:tileWidth * y];
        }
        
        // Draw small image.
        CGRect rect = CGPathGetBoundingBox(path);
        CGRect pieceRect = CGRectMake(rect.origin.x, imageHeight - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
        
        CGImageRef pieceImage = CGImageCreateWithImageInRect(_puzzleImage, pieceRect);
        
        CGContextRef context = [self createPieceContextWithWidth:rect.size.width andHeight:rect.size.height];
        CGContextSetShouldAntialias(context, aa);
        
        CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(pieceImage), CGImageGetHeight(pieceImage)), pieceImage);
        
        image = CGBitmapContextCreateImage(context);
        [images addObject:[NSValue valueWithPointer:image]];
        
        CGPathRelease(path);
        CGContextRelease(context);
        CGImageRelease(pieceImage);
    }
    
    return image;
}

- (CGImageRef) getStrokedImage {
    if (strokedImage) {
        CGImageRelease(strokedImage);
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(_puzzleImage), CGImageGetHeight(_puzzleImage),
                                                 CGImageGetBitsPerComponent(_puzzleImage), CGImageGetBytesPerRow(_puzzleImage),
                                                 CGImageGetColorSpace(_puzzleImage), CGImageGetBitmapInfo(_puzzleImage));
    
    CGContextSetShouldAntialias(context, YES);
    
    if ([[[[DBManager getInstance] getUser] showSilhouette] boolValue]) {
        CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), _puzzleImage);
    }
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageWidth, 0);
    CGContextAddLineToPoint(context, imageWidth, imageHeight);
    CGContextAddLineToPoint(context, 0, imageHeight);
    CGContextAddLineToPoint(context, 0, 0);
    
    CGContextSetFillColorWithColor(context, [[UIColor alloc] initWithRed:255 green:255 blue:255 alpha:self.backGroundAlpha].CGColor);
    CGContextFillPath(context);
    
    CGContextSetLineWidth(context, 1.0);
    
    if ([[[[DBManager getInstance] getUser] showOutlines] boolValue]) {
        for (int y = 0; y < self.tilesY; y++) {
            for (int x = 0; x < self.tilesX; x++) {
                CGContextSaveGState(context);
                
                CGMutablePathRef path;
                
                if(_difficultyValue == DIFFICULTY_SUPER_EASY)
                {
                    path = [self createSquareMaskAtX:x andY:y];
                } else {
                    Shape *shape = shapes[y * self.tilesX + x];
                    path = [self createMaskWithTopTap:shape.top rightTab:shape.right bottomTab:shape.bottom leftTab:shape.left
                                                  atX:tileWidth * x andY:tileWidth * y];
                }
                
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.2].CGColor);
                CGContextAddPath(context, path);
                CGContextStrokePath(context);
                
                CGPathRelease(path);
                CGContextRestoreGState(context);
            }
        }
    }
    
    strokedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return strokedImage;
}

- (CGMutablePathRef) createSquareMaskAtX: (CGFloat) x andY: (CGFloat) y {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x*tileWidth, y*tileHeight);
    CGPathAddLineToPoint(path, NULL, (x+1)*tileWidth, y*tileHeight);
    CGPathAddLineToPoint(path, NULL, (x+1)*tileWidth, (y+1)*tileHeight);
    CGPathAddLineToPoint(path, NULL, x*tileWidth, (y+1)*tileHeight);
    
    // Close the path
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGMutablePathRef) createMaskWithTopTap:(NSInteger) topTap rightTab:(NSInteger) rightTab bottomTab:(NSInteger) bottomTab leftTab:(NSInteger) leftTab
                                      atX: (CGFloat) x andY: (CGFloat) y {
    
    static CGFloat curvyCoords[] = {0, 0, 35, 15, 37, 5,
        37, 5, 40, 0, 38, -5,
        38, -5, 20, -20, 50, -20,
        50, -20, 80, -20, 62, -5,
        62, -5, 60, 0, 63, 5,
        63, 5, 65, 15, 100, 0};
    
    CGMutablePathRef path = CGPathCreateMutable();
    int numberOfPoints = (sizeof(curvyCoords) / sizeof(int)) / 6;
    
    CGFloat topLeftX = x + 0;
    CGFloat topLeftY = y + 0;
    
    CGFloat topRightX = topLeftX + tileWidth;
    CGFloat topRightY = topLeftY + 0;
    
    CGFloat bottomRightX = topRightX + 0;
    CGFloat bottomRightY = topRightY + tileWidth;
    
    CGFloat bottomLeftX = bottomRightX - tileWidth;
    CGFloat bottomLeftY = bottomRightY - 0;
    
    CGPathMoveToPoint(path, NULL, topLeftX, topLeftY);
    
    // Top
    for (int i = 0; i < numberOfPoints; i++) {
        if (topTap == 0) {
            CGPathAddLineToPoint(path, NULL, topRightX, topRightY);
        } else {
            CGFloat p1X = topLeftX + curvyCoords[i * 6 + 0] * tileRatio;
            CGFloat p1Y = topLeftY + curvyCoords[i * 6 + 1] * tileRatio * topTap;
            
            CGFloat p2X = topLeftX + curvyCoords[i * 6 + 2] * tileRatio;
            CGFloat p2Y = topLeftY + curvyCoords[i * 6 + 3] * tileRatio * topTap;
            
            CGFloat p3X = topLeftX + curvyCoords[i * 6 + 4] * tileRatio;
            CGFloat p3Y = topLeftY + curvyCoords[i * 6 + 5] * tileRatio * topTap;
            
            CGPathAddCurveToPoint(path, NULL, p1X, p1Y, p2X, p2Y, p3X, p3Y);
        }
    }
    
    // Right
    for (int i = 0; i < numberOfPoints; i++) {
        if (rightTab == 0) {
            CGPathAddLineToPoint(path, NULL, bottomRightX, bottomRightY);
        } else {
            CGFloat p1X = topRightX - rightTab * curvyCoords[i * 6 + 1] * tileRatio;
            CGFloat p1Y = topRightY + curvyCoords[i * 6 + 0] * tileRatio;
            
            CGFloat p2X = topRightX - rightTab * curvyCoords[i * 6 + 3] * tileRatio;
            CGFloat p2Y = topRightY + curvyCoords[i * 6 + 2] * tileRatio;
            
            CGFloat p3X = topRightX - rightTab * curvyCoords[i * 6 + 5] * tileRatio;
            CGFloat p3Y = topRightY + curvyCoords[i * 6 + 4] * tileRatio;
            
            CGPathAddCurveToPoint(path, NULL, p1X, p1Y, p2X, p2Y, p3X, p3Y);
        }
    }
    
    // Bottom
    for (int i = 0; i < numberOfPoints; i++) {
        if (bottomTab == 0) {
            CGPathAddLineToPoint(path, NULL, bottomLeftX, bottomLeftY);
        } else {
            CGFloat p1X = bottomRightX - curvyCoords[i * 6 + 0] * tileRatio;
            CGFloat p1Y = bottomRightY - bottomTab * curvyCoords[i * 6 + 1] * tileRatio;
            
            CGFloat p2X = bottomRightX - curvyCoords[i * 6 + 2] * tileRatio;
            CGFloat p2Y = bottomRightY - bottomTab * curvyCoords[i * 6 + 3] * tileRatio;
            
            CGFloat p3X = bottomRightX - curvyCoords[i * 6 + 4] * tileRatio;
            CGFloat p3Y = bottomRightY - bottomTab * curvyCoords[i * 6 + 5] * tileRatio;
            
            CGPathAddCurveToPoint(path, NULL, p1X, p1Y, p2X, p2Y, p3X, p3Y);
        }
    }
    
    // Left
    for (int i = 0; i < numberOfPoints; i++) {
        if (leftTab == 0) {
            CGPathAddLineToPoint(path, NULL, topLeftX, topLeftY);
        } else {
            CGFloat p1X = bottomLeftX + leftTab * curvyCoords[i * 6 + 1] * tileRatio;
            CGFloat p1Y = bottomLeftY - curvyCoords[i * 6 + 0] * tileRatio;
            
            CGFloat p2X = bottomLeftX + leftTab * curvyCoords[i * 6 + 3] * tileRatio;
            CGFloat p2Y = bottomLeftY - curvyCoords[i * 6 + 2] * tileRatio;
            
            CGFloat p3X = bottomLeftX + leftTab * curvyCoords[i * 6 + 5] * tileRatio;
            CGFloat p3Y = bottomLeftY - curvyCoords[i * 6 + 4] * tileRatio;
            
            CGPathAddCurveToPoint(path, NULL, p1X, p1Y, p2X, p2Y, p3X, p3Y);
        }
    }
    
    // Close the path
    CGPathCloseSubpath(path);
    
    return path;
}

- (void) computeRandomShapes {
    shapes = [NSMutableArray new];
    
    for (int y = 0; y < self.tilesY; y++) {
        for (int x = 0; x < self.tilesX; x++) {
            
            NSInteger topTab = INT_MAX;
            NSInteger rightTab = INT_MAX;
            NSInteger bottomTab = INT_MAX;
            NSInteger leftTab = INT_MAX;
            
            if (y == 0)
                topTab = 0;
            
            if (y == self.tilesY - 1)
                bottomTab = 0;
            
            if (x == 0)
                leftTab = 0;
            
            if (x == self.tilesX - 1)
                rightTab = 0;
            
            Shape *shape = [Shape new];
            shape.top = topTab;
            shape.right = rightTab;
            shape.bottom = bottomTab;
            shape.left = leftTab;
            
            [shapes addObject:shape];
        }
    }
    
    for (int y = 0; y < self.tilesY; y++) {
        for (int x = 0; x < self.tilesX; x++) {
            
            Shape *shape = shapes[y * self.tilesX + x];
            
            Shape *shapeRight = (x < self.tilesX - 1) ?
            shapes[y * self.tilesX + (x + 1)] :
            nil;
            
            Shape *shapeBottom = (y < self.tilesY - 1) ?
            shapes[(y + 1) * self.tilesX + x] :
            nil;
            
            shape.right = (x < self.tilesX - 1) ?
            [self getRandomTabValue] :
            shape.right;
            
            if (shapeRight != nil) {
                shapeRight.left = - shape.right;
            }
            
            shape.bottom = (y < self.tilesY - 1) ?
            [self getRandomTabValue] :
            shape.bottom;
            
            if (shapeBottom != nil) {
                shapeBottom.top = - shape.bottom;
            }
        }
    }
}

- (NSInteger) getRandomTabValue {
    int r = arc4random();
    return r % 2 == 0 ? 1 : -1;
}

- (CGContextRef) createPieceContextWithWidth:(CGFloat) width andHeight:(CGFloat) height {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                                 bitsPerComponent,
                                                 0, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
   
    return context;
}

@end
