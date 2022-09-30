
# BDL - bardzo dobra loteria (very good lottery)

## Problem summary

Find an $x \in \left(0, 2^{32}-1\right)$ such that $f\left(x\right) = 147100243658956343$, where $f$ is defined in [`bdl.cpp`](bdl.cpp).
Due to platform and or libc differences, the first couple hundred results of the `rand()` function are provided in [`rand.txt`](rand.txt).

*Note: I have lost the original problem statement, so this short description will have to do but in my opinion, this problem was very fun to solve.*

## Scoring

Run `./bdl test {number}`. The point function is defined as follows:

$P(n) = max \bigg(0,\ 99 - 2*\bigg\lfloor log_2 \big ( abs\left( 147100243658956343 - f(x)\right) \bigg\rfloor\bigg)$ 

## Solution

<details>
<summary>Hint 1</summary>

The `rand()` function is always seeded with the same number.

</details>

<details>
<summary>Hint 2</summary>
Maybe we could think of the 

```cpp
    for (ull i = 2; i <= 100000000; i++)
    {
        in = ((i % 2) ? in * i : in + i) % mod2;
        if (i % 10000000 == 0)
            s2 ^= in;
    }
```

loop in terms on how it'd act on a 1st degree polynomial ?
</details>

<details>
<summary>Hint 3</summary>
Think about how many bits are changed at most in this operation.

```cpp
	s2 ^= ((ull)1 << i) * c(s2, i);
``` 

</details>

<details>
<summary>Solution</summary>

- Precompute the for loop with the `rand()` function.
- Simulate the 2 big for loops while treating the `in` variable as $x$ in a 1st deg. polynomial, such that:  
	$\quad \mathbf{if}\ 2\ |\ i$  
	$\quad \quad\left(ax + b\right) \mapsto \left(ax + b + i\right)$  
	$\quad \mathbf{else}$  
	$\quad \quad\left(ax + b\right) \mapsto \left(iax + ib\right)$  
- When reversing the xor functions, you can just check if both cases when $i$-th bit is $1$ or $0$.  
	$\quad b := x \oplus \left(1 \ll i \right)$  
	$\quad \mathbf{if}\ x = \left(b\ \oplus\ \left(1\gg i \right)\right) * c\left(b, i\right)$  
	$\quad \quad x \leftarrow b$  
	This leaves us with just the xor-shifts from step 2 which you can either compute by hand in $O\left(1\right)$ using inverse modulo or just iterating over the whole domain and computing the now optimized function for every possible input, which should still take less than an hour in the worst case. *(the CUDA version runs in less than a minute on my RTX 2080)*

</details>
