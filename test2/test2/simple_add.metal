//
//  add.metal
//  test2
//
//  Created by afsara benazir on 6/18/25.
//

#include <metal_stdlib>
using namespace metal;

kernel void simple_add(device float *output [[ buffer(0) ]],
                       uint tid [[ thread_position_in_grid ]]) {
    output[tid] = tid * 2.0f;
}
