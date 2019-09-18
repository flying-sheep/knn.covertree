#' kNN search
#' 
#' k nearest neighbor search with custom distance function.
#' 
#' @param data      Data matrix
#' @param query     Query matrix. In \code{knn} and \code{knn_asym}, query and data are identical
#' @param k         Number of nearest neighbors
#' @param ...       Unused. All parameters to the right of the \code{...} have to be specified by name (e.g. \code{find_knn(data, k, distance = 'cosine')})
#' @param distance  Distance metric to use. Allowed measures: Euclidean distance (default), cosine distance (\eqn{1-corr(c_1, c_2)}) or rank correlation distance (\eqn{1-corr(rank(c_1), rank(c_2))})
#' @param sym       Return a symmetric matrix (as long as query is NULL)?
#' 
#' @return A \code{\link{list}} with the entries:
#' \describe{
#'   \item{\code{index}}{A \eqn{nrow(data) \times k} \link{integer} \link{matrix} containing the indices of the k nearest neighbors for each cell.}
#'   \item{\code{dist}}{A \eqn{nrow(data) \times k} \link{double} \link{matrix} containing the distances to the k nearest neighbors for each cell.}
#'   \item{\code{dist_mat}}{
#'     A \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} if \code{sym == TRUE},
#'     else a \code{\link[Matrix:dsCMatrix-class]{dsCMatrix}} (\eqn{nrow(query) \times nrow(data)}).
#'     Any zero in the matrix (except for the diagonal) indicates that the cells in the corresponding pair are close neighbors.
#'   }
#' }
#' 
#' @examples
#' # The default: symmetricised pairwise distances between all rows
#' pairwise <- find_knn(mtcars, 5L)
#' image(as.matrix(pairwise$dist_mat))
#' 
#' # Nearest neighbors of a subset within all
#' mercedeses <- grepl('Merc', rownames(mtcars))
#' merc_vs_all <- find_knn(mtcars, 5L, query = mtcars[mercedeses, ])
#' # Replace row index matrix with row name matrix
#' matrix(
#'   rownames(mtcars)[merc_vs_all$index],
#'   nrow(merc_vs_all$index),
#'   dimnames = list(rownames(merc_vs_all$index), NULL)
#' )[, -1]  # 1st nearest neighbor is always the same row
#' 
#' @rdname knn
#' @export
find_knn <- function(data, k, ..., query = NULL, distance = c('euclidean', 'cosine', 'rankcor'), sym = TRUE) {
	chkDots(...)
	if (is.null(dim(data))) stop('data needs to be a ')
	data <- to_matrix(data)
	distance <- match.arg(distance)
	if (is.null(query)) {
		knn <- knn_asym(data, k, distance)
		if (sym) knn$dist_mat <- symmetricise(knn$dist_mat)
			nms <- rownames(data)
	} else {
		knn <- knn_cross(data, to_matrix(query), k, distance)
		nms <- rownames(query)
	}
	rownames(knn$dist_mat) <- rownames(knn$index) <- rownames(knn$dist) <- nms
	colnames(knn$dist_mat) <- rownames(data)
	knn
}


#' @importFrom methods is
to_matrix <- function(x) {
	name <- deparse(substitute(x))
	if (is.double(x))
		return(x)
	if (is.data.frame(x)) {
		if (!all(sapply(x, is.numeric)))
			stop('find_knn parameter "', name, '" only works on numeric data.frames.')
	} else if (!is.integer(x)) {
		type <- if (is(x, 'sparseMatrix')) 'sparse matrices' else class(x)[[1L]]
		warning('find_knn parameter "', name, '" does not specifically support ', type, ', converting data to a dense matrix.')
	}
	as.matrix(x)
}


# (double generic columnsparse to ... symmetric ...: dgCMatrix -> dsCMatrix)
# retain all differences fully. symmpart halves them in the case of trans_p[i,j] == 0 && trans_p[j,i] > 0
# TODO: could be more efficient
#' @importFrom methods as
#' @importFrom Matrix symmpart skewpart forceSymmetric
symmetricise <- function(dist_asym) {
	dist_sym <- symmpart(dist_asym) + abs(forceSymmetric(skewpart(dist_asym), 'U'))
	as(dist_sym, 'symmetricMatrix')
}
