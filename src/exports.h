#ifndef _DESTINY_EXPORTS_H
#define _DESTINY_EXPORTS_H

#include <RcppEigen.h>
#include <Rcpp.h>

using namespace Rcpp;

List knn_cross(const NumericMatrix data, const NumericMatrix query, const size_t k, const std::string distance);
List knn_asym(const NumericMatrix data, const size_t k, const std::string distance);
NumericMatrix rank_mat(const NumericMatrix x);

#endif