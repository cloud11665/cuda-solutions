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

int main()
{
    ios_base::sync_with_stdio(0);
    ull in, s2 = 0;
    cin >> in;
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
    cout << s2 << ' ';
}