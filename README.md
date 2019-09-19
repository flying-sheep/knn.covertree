knn.covertree [![Workflow badge][]](https://github.com/flying-sheep/knn.covertree/commits/master)
=============


[Workflow badge]: https://github.com/flying-sheep/knn.covertree/workflows/Build%20R%20package/badge.svg

A package for precise approximative nearest neighbor search in more than just euclidean space.

Its only exported function `find_knn` computes the `k` nearest neighbors of the rows of the `query` matrix in the `data` matrix.
If no `query` matrix is passed, the nearest neighbors for all rows in the data will be returned (i.e. `data` will be used as `query`).

[generic]: https://stat.ethz.ch/R-manual/R-devel/library/Matrix/html/dgCMatrix-class.html
[symmetric]: https://stat.ethz.ch/R-manual/R-devel/library/Matrix/html/dsCMatrix-class.html

```r
find_knn(
  data, k, ...,
  query = NULL,
  distance = c("euclidean", "cosine", "rankcor"),
  sym = TRUE)
```

The result will be a list containing

- `index`, a `nrow(query)` × `k` integer matrix containing the row indices into `data` that are the nearest neighbors.
- `dist`, a `nrow(query)` × `k` double matrix containing the `distance`s to those neighbors.
- `dist_mat`, a `nrow(query)` × `nrow(data)` a `Matrix::dSparseMatrix`,
  [generic][] if `!sym` or `!is.null(query)`, and [symmetric][] if `sym` and `is.null(query)`.
  Zeros in this matrix mean “not a knn”, and if `sym` is set, the matrix will be post processed to be symmetric.
  
  (Without post processing, the matrix will likely be asymmetric as `r1∈kNN(r2)` does not imply `r2∈knn(r1)`)

This package was separated from [destiny][] as it might prove helpful in other contexts.
It provides more distance metrics than [FNN][] and is more precise than [RcppHNSW][], but slower than both.

If anyone knows a faster and similarly precise kNN search in cosine (=rank correlation) space, please tell me!

[destiny]: http://bioconductor.org/packages/destiny/
[FNN]: https://CRAN.R-project.org/package=FNN
[RcppHNSW]: https://github.com/jlmelville/rcpphnsw
