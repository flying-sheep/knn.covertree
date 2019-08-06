context('kNN integrity')

find_data <- function()
	as.list(as.environment('package:datasets')) %>%
	purrr::keep(function(d) length(dim(d)) == 2 && all(apply(d, 1, is.numeric))) %>%
	tibble::enframe(value = 'dataset') %>%
	dplyr::rowwise() %>%
	dplyr::mutate(nrow = nrow(dataset), ncol = ncol(dataset)) %>%
	print(n = Inf)

test_that('knn works the same as FNN', {
	skip_if_not_installed('FNN')
	
	e <- as.matrix(datasets::mtcars)
	
	r_destiny <- find_knn(e, 5L)
	r_fnn <- FNN::get.knn(e, 5L)
	
	dimnames(r_destiny$index) <- dimnames(r_destiny$dist) <- NULL
	expect_identical(r_destiny$dist, r_fnn$nn.dist)
})

test_that('knnx works the same as to FNN', {
	skip_if_not_installed('FNN')
	
	e <- as.matrix(datasets::mtcars)
	am <- factor(e[, 'am'], labels = c('automatic', 'manual'))
	
	r_destiny <- find_knn(e[am == 'manual',], 5L, query = e[am == 'automatic',])
	r_fnn <- FNN::get.knnx(e[am == 'manual', ], e[am == 'automatic', ], 5L)
	
	dimnames(r_destiny$index) <- dimnames(r_destiny$dist) <- NULL
	expect_identical(r_destiny$dist, r_fnn$nn.dist)
})
