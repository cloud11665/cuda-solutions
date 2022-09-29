// nvcc -arch=native -O3 bdl.cu -o bdl
#include <cuda_runtime.h>
#include <stdio.h>
#include <assert.h>

#define CUDA_CALL( ... ) do {                                               \
    __VA_ARGS__;                                                            \
    cudaError_t __res = cudaGetLastError();                                 \
    if (cudaSuccess != __res)                                               \
        fprintf(stderr, "CUDA error %i in %s:%d: %s (%s)\n",                \
        __res, __FILE__, __LINE__, cudaGetErrorString(__res), #__VA_ARGS__);\
} while(0)

using ll = long long;
using ull = unsigned long long;

struct poly { ull x1, x0; };

ull base = 147100243658956343ull;
ull _mod = 7759751235135804287ull;
ull _mod2 = 4189298803ull;
__device__ ull mod;
__device__ ull mod2;
__device__ ull _x;
poly *__poly;

int sz;
constexpr int mx = INT_MAX;

__global__ void device_ctors(ull x)
{
    mod = 7759751235135804287ull;
    mod2 = 4189298803ull;
    _x = x;
}

__global__ void kernel(poly* _poly, int start)
{
	start += threadIdx.x;
	ull in = start;
    ull s2 = 0;

    in *= 123456789;
    in %= mod2;

    s2 ^= ((in*_poly[0].x1)%mod2+_poly[0].x0)%mod2;
    s2 ^= ((in*_poly[1].x1)%mod2+_poly[1].x0)%mod2;
    s2 ^= ((in*_poly[2].x1)%mod2+_poly[2].x0)%mod2;
    s2 ^= ((in*_poly[3].x1)%mod2+_poly[3].x0)%mod2;
    s2 ^= ((in*_poly[4].x1)%mod2+_poly[4].x0)%mod2;
    s2 ^= ((in*_poly[5].x1)%mod2+_poly[5].x0)%mod2;
    s2 ^= ((in*_poly[6].x1)%mod2+_poly[6].x0)%mod2;
    s2 ^= ((in*_poly[7].x1)%mod2+_poly[7].x0)%mod2;
    s2 ^= ((in*_poly[8].x1)%mod2+_poly[8].x0)%mod2;
    s2 ^= ((in*_poly[9].x1)%mod2+_poly[9].x0)%mod2;
    in = (in*_poly[9].x1+_poly[9].x0)%mod2;
    in = s2;
    s2 ^= ((in*_poly[0].x1)%mod2+_poly[0].x0)%mod2;
    s2 ^= ((in*_poly[1].x1)%mod2+_poly[1].x0)%mod2;
    s2 ^= ((in*_poly[2].x1)%mod2+_poly[2].x0)%mod2;
    s2 ^= ((in*_poly[3].x1)%mod2+_poly[3].x0)%mod2;
    s2 ^= ((in*_poly[4].x1)%mod2+_poly[4].x0)%mod2;
    s2 ^= ((in*_poly[5].x1)%mod2+_poly[5].x0)%mod2;
    s2 ^= ((in*_poly[6].x1)%mod2+_poly[6].x0)%mod2;
    s2 ^= ((in*_poly[7].x1)%mod2+_poly[7].x0)%mod2;
    s2 ^= ((in*_poly[8].x1)%mod2+_poly[8].x0)%mod2;
    s2 ^= ((in*_poly[9].x1)%mod2+_poly[9].x0)%mod2;
    in = (in*_poly[9].x1+_poly[9].x0)%mod2;
    s2 *= s2;

    if (s2 == _x) {
        printf("Found %d\n", start);
    }
}

inline ull fpow(ull pod, ull wyk)
{
    ull w = 1;
    wyk %= _mod;
    while (wyk)
    {
        if (wyk & 1)
        {
            w *= pod;
            w %= _mod;
        }
        pod *= pod;
        pod %= _mod;
        wyk /= 2;
    }
    return w;
}

inline ull c(ull b, int z)
{
    return __builtin_popcountll(fpow(b >> (z+1), b & ((1ull << z) - 1)) >> 1)%2;
}

int main()
{
	cudaDeviceProp properties;
	CUDA_CALL( cudaGetDeviceProperties(&properties, 0) );
	sz = properties.maxThreadsPerMultiProcessor;
	
	printf("::: Calculating f^-1(x) on GPU0 (%s) using %d cores.\n", properties.name, sz);
	printf("::: x = %llu, mod = %llu, mod2 = %llu\n", base, _mod, _mod2);
    printf("Memoazing rand()...\n");

	srand(_mod2);
    ll offset = 0;
    for (int i = 0; i < 100; i++)
        offset += (ull)rand() * (ull)(rand() % 2 ? 1 : -1);

    printf("rand() result: %lld\n", offset);
    printf("Multiplying xor-shift polynomials...\n");

    poly p {1, 0};
    poly coefs[10];
    int coefs_i = 0;
    for (ull i=2; i<100000001; i++) {
        if (i % 2 == 1) {
            p.x0 *= i;
            p.x0 %= _mod2;
            p.x1 *= i;
            p.x1 %= _mod2;
        } else {
            p.x0 += i;
            p.x0 %= _mod2;
        }
        if (i % 10000000 == 0) {
            printf("P_%d = (%-10llu x^1, %-10llu x^0)\n", coefs_i, p.x1, p.x0);
            coefs[coefs_i++] = p;
        }
    }
    coefs[coefs_i++] = p;

    printf("Uploading to GPU...\n");

	CUDA_CALL( cudaMalloc(&__poly, 10*sizeof(*coefs)) );
	CUDA_CALL( cudaMemcpy(__poly, coefs, 10*sizeof(*coefs), cudaMemcpyHostToDevice) );

    printf("Reversing the power-log function...\n");

    ull x = base - offset;

	for (int k = 0; k < 654321; k++)
    {
        for (int i=62; i>=0; i--)
        {
            ull a = x ^ (1ull << i);
            ull b = x;
            if (x == (b ^ ((1ull << i) * c(b, i)))) {
                x = b;
            } else if (x == (a ^ ((1ull << i) * c(a, i)))) {
                x = a;
            } else {
                printf("UNREACHABLE!");
                exit(-1);
            }
        }
    }

    printf("transformed %llu -> %llu\n", base-offset, x);
    CUDA_CALL( device_ctors<<<1, 1>>>(x) );

    printf("Running search from 0 to %d, using 1 grid(s) %d threads\n", mx, sz);
	for (ull i=0; i<mx; i+=sz) {
		CUDA_CALL( kernel<<<1, sz>>>(__poly, i) );
	}
	cudaDeviceSynchronize();
}