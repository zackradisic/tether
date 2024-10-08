const objc = @import("zig-objc");
const std = @import("std");
const Allocator = std.mem.Allocator;
const Object = objc.Object;

const TAG: usize = @as(usize, @bitCast(1)) << 63;
/// https://github.com/opensource-apple/objc4/blob/cd5e62a5597ea7a31dccef089317abb3a661c154/runtime/objc-internal.h#L203
pub fn is_tagged_pointer(id: objc.c.id) bool {
    return @as(isize, @bitCast(@intFromPtr(id))) < 0;
}

pub const NSRange = extern struct {
    location: NSUInteger,
    length: NSUInteger,
};

pub const NSMutableArray = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn array() Self {
        const Class = Self.get_class();
        const arr_id = Class.msgSend(objc.c.id, objc.sel("array"), .{});
        return Self.from_id(arr_id);
    }

    pub fn add_object(self: Self, obj: objc.Object) void {
        self.obj.msgSend(void, objc.sel("addObject:"), .{obj});
    }
};

const NSPasteboardType = objc.c.id; // NSString
pub extern "C" const NSPasteboardTypeString: NSPasteboardType;

pub const NSPasteboard = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn general_pasteboard() Self {
        const Class = Self.get_class();
        const id = Class.msgSend(objc.c.id, objc.sel("generalPasteboard"), .{});
        return Self.from_id(id);
    }

    pub fn clear_contents(self: Self) void {
        self.obj.msgSend(void, objc.sel("clearContents"), .{});
    }

    pub fn write_objects(self: Self, array: objc.Object) void {
        self.obj.msgSend(void, objc.sel("writeObjects:"), .{array});
    }

    pub fn string_for_type(self: Self, ty: NSPasteboardType) ?NSString {
        const id = self.obj.msgSend(objc.c.id, objc.sel("stringForType:"), .{ty});
        if (id == 0) {
            return null;
        }
        return NSString.from_id(id);
    }
};

pub const NSEvent = struct {
    const Self = @This();
    obj: objc.Object,

    pub const Phase = enum(NSUInteger) {
        None = 0,
        Began = 0x1 << 0,
        Stationary = 0x1 << 1,
        Changed = 0x1 << 2,
        Ended = 0x1 << 3,
        Cancelled = 0x1 << 4,
        MayBegin = 0x1 << 5,
    };

    pub usingnamespace DefineObject(@This());

    pub fn keycode(self: Self) u16 {
        return self.obj.getProperty(u16, "keyCode");
    }

    pub fn characters(self: Self) ?NSString {
        const characters_id = self.obj.getProperty(objc.c.id, "characters");
        if (characters_id == null) {
            return null;
        }
        return NSString.from_id(characters_id);
    }

    pub fn phase(self: Self) Phase {
        return self.obj.getProperty(Phase, "phase");
    }
};

pub const CGFloat = f64;

pub const CGPoint = extern struct {
    x: CGFloat,
    y: CGFloat,

    pub fn default() CGPoint {
        return CGPoint{ .x = 0.0, .y = 0.0 };
    }
};

pub const CGSize = extern struct {
    width: CGFloat,
    height: CGFloat,

    pub fn default() CGSize {
        return CGSize{ .width = 0.0, .height = 0.0 };
    }
};

pub const CGRect = extern struct {
    const Self = @This();

    origin: CGPoint,
    size: CGSize,

    pub fn new(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) Self {
        return Self{
            .origin = .{ .x = x, .y = y },
            .size = .{ .width = w, .height = h },
        };
    }

    pub fn default() CGRect {
        return CGRect{ .origin = CGPoint.default(), .size = CGSize.default() };
    }

    pub inline fn width(self: *const Self) CGFloat {
        return self.size.width;
    }

    pub inline fn widthCeil(self: *const Self) i32 {
        return @as(i32, @intFromFloat(@ceil(self.width())));
    }

    pub inline fn heightCeil(self: *const Self) i32 {
        return @as(i32, @intFromFloat(@ceil(self.height())));
    }

    pub inline fn height(self: *const Self) CGFloat {
        return self.size.height;
    }

    pub inline fn miny(self: *const Self) CGFloat {
        return self.origin.y;
    }

    pub inline fn maxy(self: *const Self) CGFloat {
        return self.origin.y + self.size.height;
    }

    pub inline fn minyCeil(self: *const Self) i32 {
        return @as(i32, @intFromFloat(@ceil(self.miny())));
    }

    pub inline fn maxyCeil(self: *const Self) i32 {
        return @as(i32, @intFromFloat(@ceil(self.maxy())));
    }
};

pub const CGGlyph = u16;

// defined as unsigned long in NSObjCRuntime.h
pub const NSUInteger = usize;

pub const MTLSize = extern struct {
    width: NSUInteger,
    height: NSUInteger,
    depth: NSUInteger,

    pub fn new(width: NSUInteger, height: NSUInteger, depth: NSUInteger) MTLSize {
        return .{
            .width = width,
            .height = height,
            .depth = depth,
        };
    }
};

pub const NSStringEncoding = enum(NSUInteger) {
    ascii = 1,
    utf8 = 4,
};

pub const NSString = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn length(self: NSString) usize {
        return self.obj.msgSend(usize, objc.sel("length"), .{});
    }

    pub fn new_with_bytes(bytes: []const u8, encoding: NSStringEncoding) NSString {
        var object = @This().alloc();
        object = object.init_with_bytes(bytes, encoding);
        return object;
    }

    pub fn new_with_bytes_no_copy(bytes: []const u8, encoding: NSStringEncoding) NSString {
        var object = @This().alloc();
        object = object.init_with_bytes_no_copy(bytes, encoding, false);
        return object;
    }

    pub fn init_with_bytes(self: NSString, bytes: []const u8, encoding: NSStringEncoding) Self {
        const new = self.obj.msgSend(Self, objc.sel("initWithBytes:length:encoding:"), .{ bytes.ptr, bytes.len, encoding });
        return new;
    }

    pub fn init_with_bytes_no_copy(self: NSString, bytes: []const u8, encoding: NSStringEncoding, free_when_done: bool) Self {
        const new = self.obj.msgSend(Self, objc.sel("initWithBytesNoCopy:length:encoding:freeWhenDone:"), .{ bytes.ptr, bytes.len, encoding, free_when_done });
        return new;
    }

    pub fn to_c_string(self: NSString, buf: []u8) ?[*:0]u8 {
        const success = self.obj.msgSend(bool, objc.sel("getCString:maxLength:encoding:"), .{ buf.ptr, buf.len, NSStringEncoding.ascii });
        if (!success) {
            return null;
        }
        return @as([*:0]u8, @ptrCast(buf));
    }

    pub fn utf8(self: NSString) [*:0]u8 {
        return self.obj.getProperty([*:0]u8, "UTF8String");
    }

    pub fn get_characters(self: NSString, buf: []u16) void {
        self.obj.msgSend(void, objc.sel("getCharacters:"), .{buf.ptr});
    }
};

pub const NSFont = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn from_name_and_size(name: NSString, font_size: CGFloat) Self {
        const Class = Self.get_class();
        const font = Class.msgSend(objc.Object, objc.sel("fontWithName:size:"), .{ name, font_size });
        return Self.from_obj(font);
    }
};

pub const NSURL = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn file_url_with_path(path: NSString) Self {
        return Self.from_obj(Self.get_class().msgSend(objc.Object, objc.sel("fileURLWithPath:"), .{path}));
    }
};

pub const NSImage = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn new_with_data(data: NSData) Self {
        return Self.alloc().init_with_data(data);
    }

    pub fn init_with_data(self: NSImage, data: NSData) Self {
        return self.obj.msgSend(Self, objc.sel("initWithData:"), .{data});
    }

    pub fn cgimage_for_proposed_rect(self: NSImage, rect: ?*CGRect, context: ?*anyopaque, hints: ?*anyopaque) objc.c.id {
        return self.obj.msgSend(objc.c.id, objc.sel("CGImageForProposedRect:context:hints:"), .{ rect, context, hints });
    }

    pub fn size(self: NSImage) CGSize {
        return self.obj.getProperty(CGSize, "size");
    }
};

pub const NSAttributedString = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn new_with_string(string: NSString, attributes: objc.Object) NSAttributedString {
        var object = @This().alloc();
        object = object.init_with_string(string, attributes);
        return object;
    }

    pub fn init_with_string(self: NSAttributedString, string: NSString, attributes: objc.Object) Self {
        const new = self.obj.msgSend(Self, objc.sel("initWithString:attributes:"), .{ string, attributes });
        return new;
    }
};

pub const NSNumber = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn from_int(value: i32) Self {
        const obj = Self.get_class().msgSend(objc.Object, objc.sel("numberWithInt:"), .{value});
        return Self.from_obj(obj);
    }

    pub fn from_enum(value: anytype) Self {
        return Self.from_int(@as(i32, @intCast(@intFromEnum(value))));
    }

    pub fn float_value(self: Self) CGFloat {
        return self.obj.msgSend(CGFloat, objc.sel("floatValue"), .{});
    }

    pub fn number_with_int(value: i32) Self {
        const obj = Self.get_class().msgSend(objc.Object, objc.sel("numberWithInt:"), .{value});
        return Self.from_obj(obj);
    }
};

pub const NSDictionary = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn new_mutable() objc.Object {
        const Class = objc.getClass("NSMutableDictionary").?;
        var dict = Class.msgSend(objc.Object, objc.sel("alloc"), .{});
        dict = dict.msgSend(objc.Object, objc.sel("init"), .{});
        return dict;
    }

    fn set(self: NSDictionary, key: objc.Object, value: objc.Object) void {
        self.obj.msgSend(void, objc.sel("setObject:forKey:"), .{ value, key });
    }
};

pub const NSData = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn new_with_bytes_no_copy(bytes: []const u8, free_when_done: bool) Self {
        const obj = Self.get_class().msgSend(objc.Object, objc.sel("dataWithBytesNoCopy:length:freeWhenDone:"), .{ bytes.ptr, bytes.len, free_when_done });
        return Self.from_obj(obj);
    }
};

pub const MTLRenderPipelineColorAttachmentDescriptorArray = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn object_at(self: Self, idx: NSUInteger) ?MTLRenderPipelineColorAttachmentDescriptor {
        const result = self.obj.msgSend(
            objc.Object,
            objc.sel("objectAtIndexedSubscript:"),
            .{@as(c_ulong, idx)},
        );
        if (result.value == null) return null;
        return MTLRenderPipelineColorAttachmentDescriptor.from_id(result.value.?);
    }
};

pub const MTLRenderPipelineColorAttachmentDescriptor = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn set_write_mask(self: Self, write_mask: MTLColorWriteMask) void {
        self.obj.setProperty("writeMask", @intFromEnum(write_mask));
    }

    pub fn set_pixel_format(self: Self, pixel_format: MTLPixelFormat) void {
        self.obj.setProperty("pixelFormat", @as(c_ulong, pixel_format));
    }

    pub fn set_blending_enabled(self: Self, blending_enabled: bool) void {
        self.obj.setProperty("blendingEnabled", blending_enabled);
    }

    pub fn set_rgb_blend_operation(self: Self, blend_op: MTLBlendOperation) void {
        self.obj.setProperty("rgbBlendOperation", @intFromEnum(blend_op));
    }

    pub fn set_alpha_blend_operation(self: Self, blend_op: MTLBlendOperation) void {
        self.obj.setProperty("alphaBlendOperation", @intFromEnum(blend_op));
    }

    pub fn set_source_rgb_blend_factor(self: Self, blend_factor: MTLBlendFactor) void {
        self.obj.setProperty("sourceRGBBlendFactor", @intFromEnum(blend_factor));
    }

    pub fn set_source_alpha_blend_factor(self: Self, blend_factor: MTLBlendFactor) void {
        self.obj.setProperty("sourceAlphaBlendFactor", @intFromEnum(blend_factor));
    }

    pub fn set_destination_rgb_blend_factor(self: Self, blend_factor: MTLBlendFactor) void {
        self.obj.setProperty("destinationRGBBlendFactor", @intFromEnum(blend_factor));
    }

    pub fn set_destination_alpha_blend_factor(self: Self, blend_factor: MTLBlendFactor) void {
        self.obj.setProperty("destinationAlphaBlendFactor", @intFromEnum(blend_factor));
    }
};

pub const MTLSamplerState = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
};

pub const MTLSamplerDescriptor = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn new() Self {
        const sampler_descriptor = objc.getClass("MTLSamplerDescriptor").?.msgSend(objc.Object, objc.sel("alloc"), .{}).msgSend(objc.Object, objc.sel("init"), .{});
        return Self.from_obj(sampler_descriptor);
    }

    pub fn set_min_filter(self: Self, min_filter: MTLSamplerMinMagFilter) void {
        self.obj.setProperty("minFilter", min_filter);
    }

    pub fn set_mag_filter(self: Self, mag_filter: MTLSamplerMinMagFilter) void {
        self.obj.setProperty("magFilter", mag_filter);
    }

    pub fn set_s_address_mode(self: Self, s_address_mode: MTLSamplerAddressMode) void {
        self.obj.setProperty("sAddressMode", s_address_mode);
    }

    pub fn set_t_address_mode(self: Self, t_address_mode: MTLSamplerAddressMode) void {
        self.obj.setProperty("tAddressMode", t_address_mode);
    }

    pub fn set_r_address_mode(self: Self, r_address_mode: MTLSamplerAddressMode) void {
        self.obj.setProperty("rAddressMode", r_address_mode);
    }

    pub fn set_lod_min_clamp(self: Self, lod_min_clamp: f32) void {
        self.obj.setProperty("lodMinClamp", lod_min_clamp);
    }

    pub fn set_lod_max_clamp(self: Self, lod_max_clamp: f32) void {
        self.obj.setProperty("lodMaxClamp", lod_max_clamp);
    }

    pub fn set_mip_filter(self: Self, mipmap_filter: MTLSamplerMipFilter) void {
        self.obj.setProperty("mipFilter", mipmap_filter);
    }
};

pub const MTKTextureLoader = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn init_with_device(device: MTLDevice) MTKTextureLoader {
        var result = MTKTextureLoader.alloc();
        result = result.initWithDevice(device);
        return result;
    }

    pub fn new_texture_with_data_and_options(self: MTKTextureLoader, data: NSData, options: NSDictionary) MTLTexture {
        var err: ?*anyopaque = null;
        const tex = self.msgSend(objc.Object, objc.sel("newTextureWithData:options:error:"), .{
            data,
            options,
            &err,
        });
        check_error(err) catch @panic("failed to make texture");
        return MTLTexture.from_obj(tex);
    }
};

pub const MTKTextureLoaderOption = objc.c.id;
pub extern "C" const MTKTextureLoaderOptionTextureUsage: MTKTextureLoaderOption;
pub extern "C" const MTKTextureLoaderOptionTextureStorageMode: MTKTextureLoaderOption;
pub extern "C" const MTKTextureLoaderOptionSRGB: MTKTextureLoaderOption;
pub extern "C" fn NSLog(format: objc.c.id) void;
// pub extern "C" const MTKTextureLoaderOptionPixelFormat: MTKTextureLoaderOption;

pub const MTLTextureType = enum(NSUInteger) {
    texture_1d = 0,
    texture_1d_array = 1,
    texture_2d = 2,
    texture_2d_array = 3,
    texture_2d_multisample = 4,
    texture_cube = 5,
    texture_cube_array = 6,
    texture_3d = 7,
    texture_2d_multisample_array = 8,
    texture_buffer = 9,
};

pub const MTLTextureUsage = enum(NSUInteger) {
    unknown = 0x0000,
    shader_read = 0x0001,
    shader_write = 0x0002,
    render_target = 0x0004,
    pixel_format_view = 0x0010,
};

pub const MTLSamplerMinMagFilter = enum(NSUInteger) {
    nearest = 0,
    linear = 1,
};

pub const MTLSamplerAddressMode = enum(NSUInteger) {
    ClampToEdge = 0,
    MirrorClampToEdge = 1,
    Repeat = 2,
    MirrorRepeat = 3,
    ClampToZero = 4,
    ClampToBorderColor = 5,
};

pub const MTLSamplerMipFilter = enum(NSUInteger) {
    NotMipmapped = 0,
    Nearest = 1,
    Linear = 2,
};

pub const MTLClearColor = struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

pub const MTLColorWriteMask = enum(NSUInteger) {
    None = 0,
    Red = 0x1 << 3,
    Green = 0x1 << 2,
    Blue = 0x1 << 1,
    Alpha = 0x1 << 0,
    All = 0xf,
};

pub const MTLLoadAction = enum(NSUInteger) {
    dont_care = 0,
    load = 1,
    clear = 2,
};

pub const MTLStoreAction = enum(NSUInteger) {
    dont_care = 0,
    store = 1,
    multisample_resolve = 2,
    store_and_multisample_resolve = 3,
    unknown = 4,
    custom_sample_depth_store = 5,
};

pub const MTLBlendOperation = enum(NSUInteger) {
    add = 0,
    subtract = 1,
    reverse_subtract = 2,
    operation_min = 3,
    operation_max = 4,
};

pub const MTLBlendFactor = enum(NSUInteger) {
    zero = 0,
    one = 1,
    source_color = 2,
    one_minus_source_color = 3,
    source_alpha = 4,
    one_minus_source_alpha = 5,
    destination_color = 6,
    one_minus_destination_color = 7,
    destination_alpha = 8,
    one_minus_destination_alpha = 9,
    source_alpha_saturated = 10,
    blend_color = 11,
    one_minus_blend_color = 12,
    blend_alpha = 13,
    one_minus_blend_alpha = 14,
    // MTLBlendFactorSource1Color              API_AVAILABLE(macos(10.12), ios(10.11)) = 15,
    // MTLBlendFactorOneMinusSource1Color      API_AVAILABLE(macos(10.12), ios(10.11)) = 16,
    // MTLBlendFactorSource1Alpha              API_AVAILABLE(macos(10.12), ios(10.11)) = 17,
    // MTLBlendFactorOneMinusSource1Alpha      API_AVAILABLE(macos(10.12), ios(10.11)) = 18,

};

// TODO: this is supposed to be an enum
pub const MTLPixelFormat = NSUInteger;
pub const MTLPixelFormatR8Unorm: NSUInteger = 10;
pub const MTLPixelFormatRGBA8Unorm: NSUInteger = 70;
pub const MTLPixelFormatRGBA16Float: NSUInteger = 115;

pub const MTLPixelFormatRGBA8Unorm_sRGB: NSUInteger = 71;
pub const MTLPixelFormatBGRA8Unorm: NSUInteger = 80;
pub const MTLPixelFormatBGRA8Unorm_sRGB: NSUInteger = 81;

pub const MTLViewport = extern struct { origin_x: f64, origin_y: f64, width: f64, height: f64, znear: f64, zfar: f64 };

pub const MTLCommandBuffer = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn new_render_command_encoder(self: Self, render_pass_descriptor: MTLRenderPassDescriptor) MTLRenderCommandEncoder {
        return self.obj.msgSend(MTLRenderCommandEncoder, objc.sel("renderCommandEncoderWithDescriptor:"), .{render_pass_descriptor});
    }

    pub fn compute_command_encoder(self: Self) MTLComputeCommandEncoder {
        return self.obj.msgSend(MTLComputeCommandEncoder, objc.sel("computeCommandEncoder"), .{});
    }

    pub fn wait_until_completed(self: Self) void {
        return self.obj.msgSend(void, objc.sel("waitUntilCompleted"), .{});
    }

    pub fn commit(self: Self) void {
        self.obj.msgSend(void, objc.sel("commit"), .{});
    }
};

pub const MTLComputeCommandEncoder = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn set_compute_pipeline_state(self: Self, compute_pipeline: MTLComputePipelineState) void {
        self.obj.msgSend(void, objc.sel("setComputePipelineState:"), .{compute_pipeline});
    }

    pub fn set_buffer(self: Self, buffer: MTLBuffer, offset: NSUInteger, idx: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("setBuffer:offset:atIndex:"), .{ buffer, offset, idx });
    }

    pub fn dispatch_threadgroups(self: Self, threadgroups_per_grid: MTLSize, threads_per_threadgroup: MTLSize) void {
        self.obj.msgSend(void, objc.sel("dispatchThreadgroups:threadsPerThreadgroup:"), .{ threadgroups_per_grid, threads_per_threadgroup });
    }

    pub fn set_bytes(self: Self, bytes: []const u8, idx: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("setBytes:length:atIndex:"), .{ bytes.ptr, bytes.len, idx });
    }

    pub fn end_encoding(self: Self) void {
        self.obj.msgSend(void, objc.sel("endEncoding"), .{});
    }
};

pub const MTLRenderCommandEncoder = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);
    pub usingnamespace MetalResource(Self);

    pub fn set_viewport(self: Self, viewport: MTLViewport) void {
        self.obj.msgSend(void, objc.sel("setViewport:"), .{viewport});
    }

    pub fn set_vertex_bytes(self: Self, bytes: []const u8, index: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("setVertexBytes:length:atIndex:"), .{ bytes.ptr, bytes.len, index });
    }

    pub fn set_render_pipeline_state(self: Self, render_pipeline: MTLRenderPipelineState) void {
        self.obj.msgSend(void, objc.sel("setRenderPipelineState:"), .{render_pipeline});
    }

    pub fn set_vertex_buffer(self: Self, buffer: MTLBuffer, offset: NSUInteger, atIndex: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("setVertexBuffer:offset:atIndex:"), .{ buffer.obj, offset, atIndex });
    }

    pub fn set_fragment_bytes(self: Self, bytes: []const u8, index: NSUInteger) void {
        return self.obj.msgSend(void, objc.sel("setFragmentBytes:length:atIndex:"), .{ bytes.ptr, bytes.len, index });
    }

    pub fn set_fragment_texture(self: Self, tex: MTLTexture, index: usize) void {
        self.obj.msgSend(void, objc.sel("setFragmentTexture:atIndex:"), .{ tex.obj, index });
    }

    pub fn set_fragment_sampler_state(self: Self, sampler_state: objc.Object, index: usize) void {
        self.obj.msgSend(void, objc.sel("setFragmentSamplerState:atIndex:"), .{ sampler_state, index });
    }

    pub fn draw_primitives(self: Self, primitive_type: MTLPrimitiveType, vertex_start: NSUInteger, vertex_count: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("drawPrimitives:vertexStart:vertexCount:"), .{ primitive_type, vertex_start, vertex_count });
    }

    pub fn draw_primitives_instanced(self: Self, primitive_type: MTLPrimitiveType, vertex_start: NSUInteger, vertex_count: NSUInteger, instance_count: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("drawPrimitives:vertexStart:vertexCount:instanceCount:"), .{ primitive_type, vertex_start, vertex_count, instance_count });
    }

    pub fn draw_indexed_primitives_instanced(self: Self, primitive_type: MTLPrimitiveType, index_count: NSUInteger, index_type: MTLIndexType, index_buffer: MTLBuffer, index_buffer_offset: NSUInteger, instance_count: NSUInteger) void {
        self.obj.msgSend(void, objc.sel("drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:"), .{ primitive_type, index_count, index_type, index_buffer, index_buffer_offset, instance_count });
    }

    pub fn end_encoding(self: Self) void {
        self.obj.msgSend(void, objc.sel("endEncoding"), .{});
    }

    pub fn set_label_comptime(self: @This(), comptime label: []const u8) void {
        self.obj.setProperty("label", NSString.new_with_bytes_no_copy(label, .utf8));
    }
};

pub const MTLPrimitiveType = enum(NSUInteger) {
    point = 0,
    line = 1,
    line_strip = 2,
    triangle = 3,
    triangle_strip = 4,
};

pub const MTLIndexType = enum(NSUInteger) {
    UInt16 = 0,
    UInt32 = 1,
};

pub const MTLBuffer = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn did_modify_range(self: Self, range: NSRange) void {
        self.obj.msgSend(void, objc.sel("didModifyRange:"), .{range});
    }

    /// Convenience wrapper around calling `self.contents()`, setting the data, and then calling `self.did_modify_range()`
    pub fn update(self: Self, comptime T: type, data: []const T, offset: usize) void {
        const contents_buf = self.contents();
        const contents_t = @as([*]T, @ptrCast(@alignCast(contents_buf)));
        @memcpy(contents_t[offset .. offset + data.len], data[0..]);
        self.did_modify_range(.{ .location = offset * @sizeOf(T), .length = data.len * @sizeOf(T) });
    }

    pub fn contents(self: Self) [*]u8 {
        return self.obj.getProperty([*]u8, "contents");
    }

    pub fn contents_typed(self: Self, comptime T: type) [*]T {
        return @ptrCast(@alignCast(self.contents()));
    }

    pub fn length(self: Self) NSUInteger {
        return self.obj.getProperty(NSUInteger, "length");
    }
};

pub const MTLRenderPassDescriptor = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn render_pass_descriptor() MTLRenderPassDescriptor {
        const Class = objc.getClass("MTLRenderPassDescriptor").?;
        const desc = Class.msgSend(
            objc.Object,
            objc.sel("renderPassDescriptor"),
            .{},
        );
        return MTLRenderPassDescriptor.from_obj(desc);
    }

    pub fn attachments(self: MTLRenderPassDescriptor) MTLRenderPassColorAttachmentDescriptorArray {
        const a = objc.Object.fromId(self.obj.getProperty(?*anyopaque, "colorAttachments"));
        return MTLRenderPassColorAttachmentDescriptorArray.from_obj(a);
    }
};

pub const MTLRenderPassColorAttachmentDescriptorArray = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn object_at(self: Self, idx: NSUInteger) ?MTLRenderPassColorAttachmentDescriptor {
        const result = self.obj.msgSend(
            objc.Object,
            objc.sel("objectAtIndexedSubscript:"),
            .{@as(c_ulong, idx)},
        );
        if (result.value == null) return null;
        return MTLRenderPassColorAttachmentDescriptor.from_id(result.value.?);
    }
};

pub const MTLRenderPassColorAttachmentDescriptor = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn set_texture(self: Self, texture: MTLTexture) void {
        self.obj.setProperty("texture", texture);
    }

    pub fn set_resolve_texture(self: Self, texture: MTLTexture) void {
        self.obj.setProperty("resolveTexture", texture);
    }

    pub fn set_load_action(self: Self, action: MTLLoadAction) void {
        self.obj.setProperty("loadAction", action);
    }

    pub fn set_store_action(self: Self, action: MTLStoreAction) void {
        self.obj.setProperty("storeAction", action);
    }

    pub fn set_clear_color(self: Self, color: MTLClearColor) void {
        self.obj.setProperty("clearColor", color);
    }
};

pub const MTKView = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());

    pub fn current_render_pass_descriptor(self: @This()) ?MTLRenderPassDescriptor {
        return MTLRenderPassDescriptor.from_obj(self.obj.getProperty(objc.Object, "currentRenderPassDescriptor"));
    }

    pub fn color_pixel_format(self: @This()) MTLPixelFormat {
        return self.obj.getProperty(MTLPixelFormat, "colorPixelFormat");
    }

    pub fn drawable_size(self: @This()) CGSize {
        return self.obj.getProperty(CGSize, "drawableSize");
    }
};

pub const MTLDevice = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn make_command_queue(self: MTLDevice) ?MTLCommandQueue {
        const value = self.obj.msgSend(objc.c.id, objc.sel("newCommandQueue"), .{});
        if (value == 0) {
            return null;
        }

        return MTLCommandQueue.from_id(value);
    }

    pub fn new_render_pipeline(self: Self, desc: MTLRenderPipelineDescriptor) !MTLRenderPipelineState {
        var err: ?*anyopaque = null;
        const sel = objc.sel("newRenderPipelineStateWithDescriptor:error:");
        const pipeline_state = self.obj.msgSend(objc.Object, sel, .{ desc.obj.value, &err });
        try check_error(err);
        return MTLRenderPipelineState.from_obj(pipeline_state);
    }

    pub fn new_compute_pipeline_with_function(self: Self, function: objc.Object) !MTLComputePipelineState {
        const err: ?*anyopaque = null;
        const pipeline_state = self.obj.msgSend(objc.Object, objc.sel("newComputePipelineStateWithFunction:error:"), .{ function, err });
        try check_error(err);
        return MTLComputePipelineState.from_obj(pipeline_state);
    }

    pub fn new_buffer_with_length(self: Self, len: NSUInteger, opts: MTLResourceOptions) ?MTLBuffer {
        const buf_id = self.obj.msgSend(objc.c.id, objc.sel("newBufferWithLength:options:"), .{ len, opts });
        if (buf_id == 0) {
            return null;
        }
        return MTLBuffer.from_id(buf_id);
    }

    pub fn new_buffer_with_bytes(self: Self, bytes: []const u8, opts: MTLResourceOptions) MTLBuffer {
        const buf = self.obj.msgSend(MTLBuffer, objc.sel("newBufferWithBytes:length:options:"), .{ bytes.ptr, bytes.len, opts });
        return buf;
    }

    pub fn new_buffer_with_bytes_no_copy(self: Self, bytes: []const u8, opts: MTLResourceOptions) MTLBuffer {
        const buf = self.obj.msgSend(MTLBuffer, objc.sel("newBufferWithBytesNoCopy:length:options:deallocator:"), .{ bytes.ptr, bytes.len, opts, @as(c_ulong, 0) });
        return buf;
    }

    pub fn new_sampler_state(self: Self, descriptor: objc.Object) MTLSamplerState {
        return MTLSamplerState.from_obj(self.obj.msgSend(objc.Object, objc.sel("newSamplerStateWithDescriptor:"), .{descriptor}));
    }

    pub fn new_texture_with_descriptor(self: Self, descriptor: MTLTextureDescriptor) MTLTexture {
        return self.obj.msgSend(MTLTexture, objc.sel("newTextureWithDescriptor:"), .{descriptor});
    }
};

pub const MTLLibrary = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn new_with_utf8_source_options_error(device: MTLDevice, source: []const u8, options: ?objc.Object) Self {
        // PERF: NSString.new_with_bytes_no_copy?
        const shader_nsstring = NSString.new_with_bytes(source, .utf8);
        defer shader_nsstring.release();

        var err: ?*anyopaque = null;
        const library = device.obj.msgSend(
            objc.Object,
            objc.sel("newLibraryWithSource:options:error:"),
            .{ shader_nsstring, if (options) |o| @as(?*anyopaque, o.value) else @as(?*anyopaque, null), &err },
        );

        check_error(err) catch @panic("failed to build library");
        return Self.from_obj(library);
    }

    pub fn new_function_with_utf8_name(self: Self, name: []const u8) MTLFunction {
        // PERF: NSString.new_with_bytes_no_copy?
        const str = NSString.new_with_bytes(
            name,
            .utf8,
        );
        defer str.release();

        const ptr = self.obj.msgSend(?*anyopaque, objc.sel("newFunctionWithName:"), .{str});
        return MTLFunction.from_obj(objc.Object.fromId(ptr.?));
    }
};

pub const MTLFunction = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);
};

pub const MTLTextureDescriptor = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn new_2d_with_pixel_format(pixel_fmt: MTLPixelFormat, width: NSUInteger, height: NSUInteger, mipmapped: bool) Self {
        return Self.get_class().msgSend(Self, objc.sel("texture2DDescriptorWithPixelFormat:width:height:mipmapped:"), .{ pixel_fmt, width, height, mipmapped });
    }

    pub fn set_usage(self: Self, usage: NSUInteger) void {
        self.obj.setProperty("usage", usage);
    }

    pub fn set_sample_count(self: Self, sample_count: NSUInteger) void {
        self.obj.setProperty("sampleCount", sample_count);
    }

    pub fn set_texture_type(self: Self, texture_type: MTLTextureType) void {
        self.obj.setProperty("textureType", @intFromEnum(texture_type));
    }

    pub fn set_storage_mode(self: Self, storage_mode: MTLStorageMode) void {
        self.obj.setProperty("storageMode", @intFromEnum(storage_mode));
    }
};

pub const MTLOrigin = extern struct {
    x: NSUInteger,
    y: NSUInteger,
    z: NSUInteger,
};

pub const MTLRegion2D = extern struct { origin: MTLOrigin, size: MTLSize };

pub const MTLTexture = struct {
    const Self = @This();
    obj: objc.Object,
    pub usingnamespace DefineObject(Self);

    pub fn replace_region_with_bytes(self: Self, region: MTLRegion2D, mipmap_level: NSUInteger, bytes: [*]const void, bytes_per_row: NSUInteger) void {
        return self.obj.msgSend(void, objc.sel("replaceRegion:mipmapLevel:withBytes:bytesPerRow:"), .{ region, mipmap_level, bytes, bytes_per_row });
    }
};

pub const MTLResourceCPUCacheModeShift: NSUInteger = 0;
pub const MTLResourceCPUCacheModeMask: NSUInteger = 0xf << MTLResourceCPUCacheModeShift;

pub const MTLResourceStorageModeShift: NSUInteger = 4;
pub const MTLResourceStorageModeMask: NSUInteger = 0xf << MTLResourceStorageModeShift;

pub const MTLResourceHazardTrackingModeShift: NSUInteger = 8;
pub const MTLResourceHazardTrackingModeMask: NSUInteger = 0x3 << MTLResourceHazardTrackingModeShift;

// TODO: these broken
pub const MTLResourceOptions = enum(NSUInteger) {
    // cpu_cache_mode_default_cache = @enumToInt(MTLCPUCacheMode.default_cache) << MTLResourceCPUCacheModeShift,
    // cpu_cache_mode_write_combined = @enumToInt(MTLCPUCacheMode.write_combined) << MTLResourceCPUCacheModeShift,

    storage_mode_shared = @intFromEnum(MTLStorageMode.shared) << MTLResourceStorageModeShift,
    storage_mode_managed = @intFromEnum(MTLStorageMode.managed) << MTLResourceStorageModeShift,
    storage_mode_private = @intFromEnum(MTLStorageMode.private) << MTLResourceStorageModeShift,
    storage_mode_memoryless = @intFromEnum(MTLStorageMode.memoryless) << MTLResourceStorageModeShift,

    // hazard_tracking_mode_default = @enumToInt(MTLHazardTrackingMode.default) << MTLResourceHazardTrackingModeShift,
    // hazard_tracking_mode_untracked = @enumToInt(MTLHazardTrackingMode.untracked) << MTLResourceHazardTrackingModeShift,
    // hazard_tracking_mode_tracked = @enumToInt(MTLHazardTrackingMode.tracked) << MTLResourceHazardTrackingModeShift,
};

pub const MTLCPUCacheMode = enum(NSUInteger) {
    default_cache = 0,
    write_combined = 1,
};

pub const MTLStorageMode = enum(NSUInteger) {
    shared = 0,
    managed = 1,
    private = 2,
    memoryless = 3,
};

pub const MTLHazardTrackingMode = enum(NSUInteger) {
    default = 0,
    untracked = 1,
    tracked = 2,
};

pub const MTLCommandQueue = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
    pub usingnamespace MetalResource(@This());

    pub fn command_buffer(self: @This()) MTLCommandBuffer {
        return self.obj.msgSend(MTLCommandBuffer, objc.sel("commandBuffer"), .{});
    }
};

pub const MTLRenderPipelineState = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
};

pub const MTLComputePipelineState = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
};

pub const MTLVertexFormat = enum(NSUInteger) {
    invalid = 0,

    uchar2 = 1,
    uchar3 = 2,
    uchar4 = 3,

    char2 = 4,
    char3 = 5,
    char4 = 6,

    uchar2_normalized = 7,
    uchar3_normalized = 8,
    uchar4_normalized = 9,

    char2_normalized = 10,
    char3_normalized = 11,
    char4_normalized = 12,

    ushort2 = 13,
    ushort3 = 14,
    ushort4 = 15,

    short2 = 16,
    short3 = 17,
    short4 = 18,

    ushort2_normalized = 19,
    ushort3_normalized = 20,
    ushort4_normalized = 21,

    short2_normalized = 22,
    short3_normalized = 23,
    short4_normalized = 24,

    half2 = 25,
    half3 = 26,
    half4 = 27,

    float = 28,
    float2 = 29,
    float3 = 30,
    float4 = 31,

    int = 32,
    int2 = 33,
    int3 = 34,
    int4 = 35,

    uint = 36,
    uint2 = 37,
    uint3 = 38,
    uint4 = 39,

    int1010102_normalized = 40,
    uint1010102_normalized = 41,

    uchar4_normalized_bgra = 42,

    uchar = 45,
    char = 46,
    uchar_normalized = 47,
    char_normalized = 48,

    ushort = 49,
    short = 50,
    ushort_normalized = 51,
    short_normalized = 52,

    half = 53,
};

pub const MTLVertexStepFunction = enum(NSUInteger) {
    Constant = 0,
    PerVertex = 1,
    PerInstance = 2,
    // MTLVertexStepFunctionPerPatch API_AVAILABLE(macos(10.12), ios(10.0)) = 3,
    // MTLVertexStepFunctionPerPatchControlPoint API_AVAILABLE(macos(10.12), ios(10.0)) = 4,
};

pub const MTLVertexDescriptor = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
    pub const Attribute = struct {
        format: MTLVertexFormat,
        offset: NSUInteger,
        buffer_index: NSUInteger,
    };
    pub const Layout = struct {
        stride: NSUInteger,
        step_function: ?MTLVertexStepFunction = null,
        step_rate: ?NSUInteger = null,
    };

    pub fn set_attribute(self: @This(), idx: NSUInteger, attrib: Attribute) void {
        const attrs = objc.Object.fromId(self.obj.getProperty(?*anyopaque, "attributes"));
        const attr = attrs.msgSend(objc.Object, objc.sel("objectAtIndexedSubscript:"), .{idx});
        attr.setProperty("format", @intFromEnum(attrib.format));
        attr.setProperty("offset", attrib.offset);
        attr.setProperty("bufferIndex", attrib.buffer_index);
    }

    pub fn set_layout(self: @This(), idx: NSUInteger, layout: Layout) void {
        const attrs = objc.Object.fromId(self.obj.getProperty(?*anyopaque, "layouts"));
        const attr = attrs.msgSend(objc.Object, objc.sel("objectAtIndexedSubscript:"), .{idx});
        attr.setProperty("stride", layout.stride);
        if (layout.step_function) |stepfn| {
            attr.setProperty("stepFunction", stepfn);
        }
        if (layout.step_rate) |steprate| {
            attr.setProperty("stepRate", steprate);
        }
    }
};

pub const MTLRenderPipelineDescriptor = struct {
    obj: objc.Object,
    pub usingnamespace DefineObject(@This());
    pub usingnamespace MetalResource(@This());

    pub fn set_vertex_function(self: @This(), func_vert: objc.Object) void {
        self.obj.setProperty("vertexFunction", func_vert);
    }

    pub fn set_fragment_function(self: @This(), func_frag: objc.Object) void {
        self.obj.setProperty("fragmentFunction", func_frag);
    }

    pub fn set_vertex_descriptor(self: @This(), vertex_desc: MTLVertexDescriptor) void {
        self.obj.setProperty("vertexDescriptor", vertex_desc);
    }

    pub fn get_color_attachments(self: @This()) MTLRenderPipelineColorAttachmentDescriptorArray {
        return MTLRenderPipelineColorAttachmentDescriptorArray.from_obj(objc.Object.fromId(self.obj.getProperty(?*anyopaque, "colorAttachments")));
    }

    pub fn set_raster_sample_count(self: @This(), sample_count: NSUInteger) void {
        self.obj.setProperty("rasterSampleCount", sample_count);
    }

    pub fn set_label_comptime(self: @This(), comptime label: []const u8) void {
        self.obj.setProperty("label", NSString.new_with_bytes_no_copy(label, .utf8));
    }
};

fn DefineObject(comptime T: type) type {
    const obj_impl = struct {
        pub fn from_id(id: anytype) T {
            switch (T) {
                // objc.Object.fromId checks that id is aligned to usize.
                // Certain objects like NSString may use tagged pointers for small allocations,
                // which are not guaranteed to be aligned.
                NSNumber, NSString => {
                    if (is_tagged_pointer(id)) {
                        return .{ .obj = .{ .value = id } };
                    }
                },
                else => {},
            }

            return .{
                .obj = Object.fromId(id),
            };
        }

        pub fn from_obj(object: objc.Object) T {
            return .{
                .obj = object,
            };
        }

        pub fn get_class() objc.Class {
            const class = objc.getClass(comptime classTypeName(T)).?;
            return class;
        }

        pub fn alloc() T {
            const class = get_class();
            const object = class.msgSend(objc.Object, objc.sel("alloc"), .{});
            return .{ .obj = object };
        }

        pub fn init(self: T) T {
            const obj = self.obj.msgSend(objc.Object, objc.sel("init"), .{});
            return from_obj(obj);
        }

        pub fn autorelease(self: T) void {
            self.obj.msgSend(void, objc.sel("autorelease"), .{});
        }

        pub fn release(self: T) void {
            self.obj.msgSend(void, objc.sel("release"), .{});
        }

        pub fn retain(self: T) void {
            self.obj.msgSend(void, objc.sel("retain"), .{});
        }
    };

    return obj_impl;
}

fn MetalResource(comptime T: type) type {
    const obj_impl = struct {
        pub fn set_label(self: T, name: []const u8) void {
            const str = NSString.new_with_bytes_no_copy(name, .ascii);
            self.obj.setProperty("label", str);
        }
    };

    return obj_impl;
}

pub const MetalError = error{Uhoh};

/// Wrapper around @typeName(T) that strips the namespaces out of the string
pub fn classTypeName(comptime T: type) [:0]const u8 {
    const str = @typeName(T);
    var i = 0;
    var last_dot_idx = -1;
    while (str[i] != 0) {
        if (str[i] == '.') {
            last_dot_idx = i;
        }
        i += 1;
    }
    if (last_dot_idx == -1) return str[0..i :0];

    return str[last_dot_idx + 1 .. i :0];
}

// pub fn check_error(err_: ?*anyopaque) !void {
//     if (err_) |err| {
//         const nserr = objc.Object.fromId(err);
//         const str =
//             nserr.getProperty(NSString, "localizedDescription");

//         var buf: [256]u8 = undefined;

//         const err_str = str.to_c_string(&buf) orelse "unknown error";
//         std.debug.print("metal error={s}\n", .{err_str});

//         return MetalError.Uhoh;
//     }
// }

pub fn check_error(err_: ?*anyopaque) !void {
    const nserr = objc.Object.fromId(err_ orelse return);
    const str = nserr.getProperty(NSString, "localizedDescription");
    var buf: [2048]u8 = undefined;
    const slice = str.to_c_string(buf[0..]) orelse @panic("FUCK");

    std.debug.print("metal error={s}", .{slice});
    return error.MetalFailed;
}

/// https://developer.apple.com/documentation/corefoundation/cfstringencoding?language=objc
pub const StringEncoding = enum(u32) {
    invalid = 0xffffffff,
    mac_roman = 0,
    windows_latin1 = 0x0500,
    iso_latin1 = 0x0201,
    nextstep_latin = 0x0B01,
    ascii = 0x0600,
    unicode = 0x0100,
    utf8 = 0x08000100,
    non_lossy_ascii = 0x0BFF,
    utf16_be = 0x10000100,
    utf16_le = 0x14000100,
    utf32 = 0x0c000100,
    utf32_be = 0x18000100,
    utf32_le = 0x1c000100,
};

// test "tagged pointer" {
//     // const raw: usize = 13251083606895578065;
//     // const str = NSString.from_tagged_id(@as(objc.c.id, raw));
//     // const raw_str = "HELLO";
//     // _ = raw_str;
//     const str = NSString.new_with_bytes("H", .ascii);
//     var buf: [256]u8 = undefined;
//     const c_str = str.to_c_string(&buf);
//     std.debug.print("HELLO {s}\n", .{c_str});
//     const str2 = NSString.from_id(str.obj.value);
//     const c_str2 = str2.to_c_string(&buf);
//     std.debug.print("HELLO {s}\n", .{c_str2});
//     const Class = NSString.get_class();
//     const str3 = Class.msgSend(NSString, objc.sel("stringWithUTF8String:"), .{"H"});
//     var buf2: [256]u8 = undefined;
//     const c_str3 = str3.to_c_string(&buf2);

//     std.debug.print("NICE {s} {d} {}\n", .{ c_str3, @ptrToInt(str3.obj.value), str3.is_tagged_pointer() });
//     // str.obj.msgSend(NSString, objc.sel("stringWithUTF8String:"), .{buf});
// }
