# skip-list

This library provides an implementation of pure [skip lists](https://en.wikipedia.org/wiki/Skip_list) in Haskell.

## Performance

NOTE: skip lists have *amortized* good performance, so you will only get a
performance benefit if you do many accesses deep into the list.

You can run the benchmarks using `stack bench`. The benchmark is the following:

```haskell
let big = [0..1000] in
big == lookup (make big) <$> big
```

For `[]`, `lookup = !!` and `make = id`.
For `SkipList`, `lookup = SL.lookup` and `make = SL.toSkipList q` where `q` is
skip length.

* For lists

```
benchmarking all/!!
time                 864.6 μs   (858.1 μs .. 873.0 μs)
                     0.999 R²   (0.999 R² .. 1.000 R²)
mean                 859.3 μs   (855.5 μs .. 864.3 μs)
std dev              14.76 μs   (11.86 μs .. 21.57 μs)
```

* For `SkipList` (`q = 32`)

```
benchmarking Quantities/SkipList<32>
time                 134.9 μs   (134.0 μs .. 135.7 μs)
                     1.000 R²   (0.999 R² .. 1.000 R²)
mean                 134.0 μs   (133.6 μs .. 134.5 μs)
std dev              1.559 μs   (1.317 μs .. 1.958 μs)
```