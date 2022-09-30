// g++ bdl.cpp -O3 -obdl -fwhole-program
#include <bits/stdc++.h>
#define ull unsigned long long
#define MOD srand
using namespace std;

const ull mod = 7759751235135804287, mod2 = 4189298803, _max = 2147483648;

ull fpow(ull pod, ull wyk)
{
    ull w = 1;
    while (wyk)
    {
        if (wyk & 1)
        {
            w *= pod;
            w %= mod;
        }
        pod *= pod;
        pod %= mod;
        wyk /= 2;
    }
    return w;
}

ull c(ull b, int z)
{
    ull C = fpow(b / ((ull)2 << z), b % ((ull)1 << z));
    ull w = 0;
    while (C /= 2)
        w ^= (C % 2);
    return w;
}

ull f(ull in)
{
    ull s2 = 0;
    assert(in == (in % _max));
    in *= 123456789;
    in %= mod2;
    for (ull i = 2; i <= 100000000; i++)
    {
        in = ((i % 2) ? in * i : in + i) % mod2;
        if (i % 10000000 == 0)
            s2 ^= in;
    }
    in = s2;
    for (ull i = 2; i <= 100000000; i++)
    {
        in = ((i % 2) ? in * i : in + i) % mod2;
        if (i % 10000000 == 0)
            s2 ^= in;
    }
    (s2 *= s2) % mod2;
    MOD(mod2);
    for (int j = 0; j < 654321; j++)
        for (ull i = 0; i <= 62; i++)
            s2 ^= ((ull)1 << i) * c(s2, i);
    
    for (int i = 0; i < 100; i++)
        s2 += (ull)rand() * (ull)(rand() % 2 ? 1 : -1);
    return s2;
}

int main(int argc, char **argv)
{
    switch (argc) {
    break;case 1:
        cout << "Usage: " << argv[0] << " [test] number\n";
    break;case 2:
        cout << f(atoll(argv[1])) << "\n";
    break;case 3:
        if (0 != strcasecmp(argv[1], "test")) return EXIT_FAILURE;
        ull diff = f(atoll(argv[2]));
        if (diff > 147100243658956343ull)
            diff = diff -147100243658956343ull;
        else
            diff = 147100243658956343ull - diff;
        cout << max(0, 99 - 2*(int)log2(diff)) << "\n";
    }
}