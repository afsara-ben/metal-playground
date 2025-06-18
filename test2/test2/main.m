//
//  main.m
//  test2
//
//  Created by afsara benazir on 6/18/25.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        id<MTLCommandQueue> queue = [device newCommandQueue];

        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"metallib"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        dispatch_data_t dispatchData = dispatch_data_create([data bytes], [data length], NULL, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
        id<MTLLibrary> library = [device newLibraryWithData:dispatchData error:&error];

        id<MTLFunction> func = [library newFunctionWithName:@"simple_add"];
        id<MTLComputePipelineState> pipeline = [device newComputePipelineStateWithFunction:func error:&error];

        const int count = 16;
        id<MTLBuffer> buffer = [device newBufferWithLength:count * sizeof(float)
                                                    options:MTLResourceStorageModeShared];

        id<MTLCommandBuffer> cmdBuf = [queue commandBuffer];
        id<MTLComputeCommandEncoder> encoder = [cmdBuf computeCommandEncoder];
        [encoder setComputePipelineState:pipeline];
        [encoder setBuffer:buffer offset:0 atIndex:0];

        MTLSize tg = MTLSizeMake(8, 1, 1);
        MTLSize grid = MTLSizeMake(count, 1, 1);
        [encoder dispatchThreads:grid threadsPerThreadgroup:tg];
        [encoder endEncoding];

        [cmdBuf commit];
        [cmdBuf waitUntilCompleted];

        float *out = buffer.contents;
        for (int i = 0; i < count; i++) {
            printf("output[%d] = %f\n", i, out[i]);
        }
    }
    return 0;
}
