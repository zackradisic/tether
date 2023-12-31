const objc = @import("zig-objc");
const metal = @import("./metal.zig");

pub const CTFontRef = objc.c.id;
pub const Unichar = u16;
pub const CFIndex = i64;

pub const CTFontOrientation = enum(u32) {
    default = 0,
    horizontal = 1,
    vertical = 2,
};

pub const CFRange = extern struct {
    location: CFIndex,
    length: CFIndex,
};

pub const CGAffineTransform = extern struct {
    a: metal.CGFloat,
    b: metal.CGFloat,
    c: metal.CGFloat,
    d: metal.CGFloat,
    tx: metal.CGFloat,
    ty: metal.CGFloat,
};

pub const CTTextAlignment = enum(u8) {
    Left = 0,
    Right = 1,
    Center = 2,
    Justified = 3,
    Natural = 4,
};

pub const CTParagraphStyleSpecifier = enum(u32) {
    Alignment = 0,
    FirstLineHeadIndent = 1,
    HeadIndent = 2,
    TailIndent = 3,
    TabStops = 4,
    DefaultTabInterval = 5,
    LineBreakMode = 6,
    LineHeightMultiple = 7,
    MaximumLineHeight = 8,
    MinimumLineHeight = 9,
    // kCTParagraphStyleSpecifierLineSpacing CT_ENUM_DEPRECATED("See documentation for replacements", macos(10.5, 10.8), ios(3.2, 6.0)) CT_ENUM_UNAVAILABLE(watchos, tvos) = 10,
    ParagraphSpacing = 11,
    ParagraphSpacingBefore = 12,
    BaseWritingDirection = 13,
    MaximumLineSpacing = 14,
    MinimumLineSpacing = 15,
    LineSpacingAdjustment = 16,
    LineBoundsOptions = 17,

    Count,
};

pub const CTParagraphStyleSetting = extern struct {
    spec: CTParagraphStyleSpecifier,
    value_size: usize,
    value: *const anyopaque,
};

pub extern "C" const CGAffineTransformIdentity: CGAffineTransform;

pub const CFTypeRef = objc.c.id;
pub const CFStringRef = objc.c.id;
pub const CFAttributedStringRef = objc.c.id;
pub const CFMutableAttributedStringRef = objc.c.id;
pub const CFArrayRef = objc.c.id;
pub const CGContextRef = objc.c.id;
pub const CGColorSpaceRef = objc.c.id;
pub const CGColorRef = objc.c.id;
pub const CGFontRef = objc.c.id;
pub const CGImageRef = objc.c.id;
pub const CTFramesetterRef = objc.c.id;
pub const CTFrameRef = objc.c.id;
pub const CTLineRef = objc.c.id;
pub const CTRunRef = objc.c.id;
pub const CGPathRef = objc.c.id;
pub const CFAllocatorRef = ?*anyopaque;
pub const CTParagraphStyleRef = objc.c.id;

pub extern "C" const kCGColorSpaceSRGB: objc.c.id;
pub extern "C" const kCTFontBaselineAdjustAttribute: objc.c.id;
pub extern "C" const kCTLigatureAttributeName: objc.c.id;
pub extern "C" const kCTFontAttributeName: objc.c.id;
pub extern "C" const kCTParagraphStyleAttributeName: objc.c.id;
// pub extern "C" const kCGImageAlphaNone: u32;
pub const kCGBitmapAlphaInfoMask: u32 = 0x1F;
pub const kCGImageAlphaNone: u32 = 0;
pub const kCGImageAlphaPremultipliedLast: u32 = 1;
pub const kCGImageByteOrderDefault: u32 = 0 << 12;

pub extern "C" fn CTFontGetAscent(font: CTFontRef) metal.CGFloat;
pub extern "C" fn CTFontGetDescent(font: CTFontRef) metal.CGFloat;
pub extern "C" fn CTFontGetLeading(font: CTFontRef) metal.CGFloat;
pub extern "C" fn CTFontGetBoundingBox(font: CTFontRef) metal.CGRect;
pub extern "C" fn CTFontGetGlyphsForCharacters(font: CTFontRef, characters: [*]const Unichar, glyphs: [*]metal.CGGlyph, count: CFIndex) bool;
pub extern "C" fn CTFontGetBoundingRectsForGlyphs(font: CTFontRef, orientation: CTFontOrientation, glyphs: [*]const metal.CGGlyph, bounding_rects: [*]metal.CGRect, count: CFIndex) metal.CGRect;
pub extern "C" fn CTFontCopyGraphicsFont(font: CTFontRef, attributes: ?[*]const objc.c.id) objc.c.id;
pub extern "C" fn CTFontGetAdvancesForGlyphs(font: CTFontRef, orientation: CTFontOrientation, glyphs: [*]const metal.CGGlyph, advances: [*]metal.CGSize, count: CFIndex) f64;
pub extern "C" fn CTFontCopyAttribute(font: CTFontRef, attribute: CFStringRef) CFTypeRef;
pub extern "C" fn CTFontGetLigatureCaretPositions(font: CTFontRef, glyph: metal.CGGlyph, positions: [*]metal.CGFloat, max_positions: CFIndex) CFIndex;
pub extern "C" fn CTFontCreatePathForGlyph(font: CTFontRef, glyph: metal.CGGlyph, transform: ?*const CGAffineTransform) CGPathRef;
pub extern "C" fn CTFramesetterCreateWithAttributedString(string: CFAttributedStringRef) CTFramesetterRef;
pub extern "C" fn CTFramesetterCreateFrame(framesetter: CTFramesetterRef, string_range: CFRange, path: CGPathRef, frame_attributes: objc.c.id) CTFrameRef;
pub extern "C" fn CTFrameGetLines(frame: CTFrameRef) CFArrayRef;
pub extern "C" fn CTFrameGetLineOrigins(frame: CTFrameRef, range: CFRange, origins: [*]metal.CGPoint) void;
pub extern "C" fn CTLineCreateWithAttributedString(string: CFAttributedStringRef) CTLineRef;
pub extern "C" fn CTLineGetTypographicBounds(line: CTLineRef, ascent: ?*metal.CGFloat, descent: ?*metal.CGFloat, leading: ?*metal.CGFloat) f64;
pub extern "C" fn CTLineGetGlyphRuns(line: CTLineRef) CFArrayRef;
pub extern "C" fn CTRunGetGlyphs(run: CTRunRef, range: CFRange, buffer: [*]metal.CGGlyph) void;
pub extern "C" fn CTRunGetGlyphCount(run: CTRunRef) CFIndex;
pub extern "C" fn CTRunGetPositions(run: CTRunRef, range: CFRange, buffer: [*]metal.CGPoint) void;
pub extern "C" fn CTRunGetTypographicBounds(run: CTRunRef, range: CFRange, ascent: ?*metal.CGFloat, descent: ?*metal.CGFloat, leading: ?*metal.CGFloat) f64;
pub extern "C" fn CTParagraphStyleCreate(settings: ?[*]const CTParagraphStyleSetting, settings_count: usize) CTParagraphStyleRef;

pub extern "C" fn CGFontGetGlyphAdvances(font: CGFontRef, glyphs: [*]metal.CGGlyph, count: usize, advances: [*]i32) bool;
pub extern "C" fn CGFontGetDescent(font: CGFontRef) i32;

pub extern "C" fn CFAttributedStringCreateMutable(alloc: objc.c.id, max_length: CFIndex) CFMutableAttributedStringRef;
pub extern "C" fn CFAttributedStringReplaceString(string: CFMutableAttributedStringRef, range: CFRange, replacement: CFStringRef) void;
pub extern "C" fn CFAttributedStringSetAttribute(string: CFMutableAttributedStringRef, range: CFRange, attribute: CFStringRef, value: CFTypeRef) void;
pub extern "C" fn CFAttributedStringGetLength(string: CFAttributedStringRef) CFIndex;

pub extern "C" fn CFArrayGetValueAtIndex(array: CFArrayRef, index: CFIndex) CFTypeRef;
pub extern "C" fn CFArrayGetCount(array: CFArrayRef) CFIndex;
// pub extern "C" fn CFDictionaryCreate(allocator: CFAllocatorRef, keys: [*]const void, values: [*]const void, num_values: CFIndex, )

pub extern "C" fn CFRelease(obj: CFTypeRef) void;

// pub extern "C" const kCGImageAlphaPremultipliedLast: u32;
pub extern "C" fn CGColorSpaceCreateWithName(name: objc.c.id) CGColorSpaceRef;
pub extern "C" fn CGColorSpaceCreateDeviceGray() CGColorSpaceRef;
pub extern "C" fn CGBitmapContextCreate(
    data: ?[*]void,
    width: usize,
    height: usize,
    bits_per_component: usize,
    bytes_per_row: usize,
    space: CGColorSpaceRef,
    bitmap_info: usize,
) CGContextRef;
pub extern "C" fn CGColorCreateGenericRGB(r: metal.CGFloat, g: metal.CGFloat, b: metal.CGFloat, a: metal.CGFloat) CGColorRef;
pub extern "C" fn CGContextClearRect(ctx: CGContextRef, rect: metal.CGRect) void;
pub extern "C" fn CGContextAddPath(ctx: CGContextRef, path: CGPathRef) void;
pub extern "C" fn CGContextFillPath(ctx: CGContextRef) void;
pub extern "C" fn CGContextSetFillColorWithColor(ctx: CGContextRef, color: CGColorRef) void;
pub extern "C" fn CGContextSetGrayFillColor(ctx: CGContextRef, gray: metal.CGFloat, alpha: metal.CGFloat) void;
pub extern "C" fn CGContextFillRect(ctx: CGContextRef, rect: metal.CGRect) void;
pub extern "C" fn CGContextStrokeRect(ctx: CGContextRef, rect: metal.CGRect) void;
pub extern "C" fn CGContextStrokeRectWithWidth(ctx: CGContextRef, rect: metal.CGRect, width: metal.CGFloat) void;
pub extern "C" fn CGContextClipToRect(ctx: CGContextRef, rect: metal.CGRect) void;
pub extern "C" fn CGContextSetStrokeColorWithColor(ctx: CGContextRef, color: CGColorRef) void;
pub extern "C" fn CGContextSetGrayStrokeColor(ctx: CGContextRef, gray: metal.CGFloat, alpha: metal.CGFloat) void;
pub extern "C" fn CGContextSetFont(ctx: CGContextRef, font: CGFontRef) void;
pub extern "C" fn CGContextSetFontSize(ctx: CGContextRef, size: metal.CGFloat) void;
pub extern "C" fn CGContextSetTextMatrix(ctx: CGContextRef, t: CGAffineTransform) void;
pub extern "C" fn CGContextSetTextPosition(ctx: CGContextRef, x: metal.CGFloat, y: metal.CGFloat) void;
pub extern "C" fn CGContextMoveToPoint(ctx: CGContextRef, x: metal.CGFloat, y: metal.CGFloat) void;
pub extern "C" fn CGContextDrawImage(ctx: CGContextRef, rect: metal.CGRect, img: CGImageRef) void;

pub extern "C" fn CGContextSetShouldAntialias(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetAllowsAntialiasing(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetShouldSmoothFonts(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetAllowsFontSmoothing(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetShouldSubpixelPositionFonts(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetShouldSubpixelQuantizeFonts(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetAllowsFontSubpixelPositioning(ctx: CGContextRef, val: bool) void;
pub extern "C" fn CGContextSetAllowsFontSubpixelQuantization(ctx: CGContextRef, val: bool) void;

pub extern "C" fn CGContextShowGlyphsAtPoint(ctx: CGContextRef, x: metal.CGFloat, y: metal.CGFloat, glyphs: [*]const metal.CGGlyph, count: usize) void;
pub extern "C" fn CGContextShowGlyphs(ctx: CGContextRef, glyphs: [*]const metal.CGGlyph, count: usize) void;
pub extern "C" fn CGBitmapContextCreateImage(ctx: CGContextRef) CGImageRef;
pub extern "C" fn CGBitmapContextGetData(ctx: CGContextRef) [*]void;

pub extern "C" fn CGImageGetWidth(img: CGImageRef) usize;
pub extern "C" fn CGImageGetHeight(img: CGImageRef) usize;

pub extern "C" fn CGPathCreateWithRect(rect: metal.CGRect, transform: ?*const CGAffineTransform) CGPathRef;

pub extern "C" fn CGImageRelease(img: CGImageRef) void;
pub extern "C" fn CGColorRelease(color: CGColorRef) void;
pub extern "C" fn CGColorSpaceRelease(space: CGColorSpaceRef) void;
pub extern "C" fn CGContextRelease(ctx: CGContextRef) void;
pub extern "C" fn CGPathRelease(path: CGPathRef) void;

pub extern "C" fn CFRetain(val: objc.c.id) objc.c.id;
