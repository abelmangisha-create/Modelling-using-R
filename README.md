# Distribution Fitting in R

A project exploring how to identify the underlying probability distribution of a dataset using multiple complementary methods in R, then statistically resolving disagreements between them.

## Overview

This project demonstrates a full distribution-fitting workflow:

1. Visual exploration via histogram and kernel density estimation
2. Distribution identification using three independent methods
3. Resolving disagreement between methods using descriptive statistics and reasoning
4. Formal comparison of the remaining candidate distributions using visual diagnostics and goodness-of-fit statistics

## Methods Used

| Method | Package | Result |
|---|---|---|
| KDE-based best fit | `simukde` | Cauchy |
| Likelihood-based fit | `gamlss` | Lognormal |
| Cullen and Frey graph | `fitdistrplus` | Lognormal or Gamma |

The three methods didn't fully agree, so the project walks through *why*, rather than just reporting the result each one returned.

## Key Findings

**Cauchy was rejected.** The data showed high skewness (skewness² ≈ 11.05) and high kurtosis (≈ 15.41), but Cauchy has undefined mean and variance, making it an implausible fit for this data shape. KDE-based methods like `simukde` are sensitive to extreme/outlying values in small samples, which can produce spurious heavy-tailed matches like Cauchy even when the bulk of the data doesn't support it.

**Lognormal and Gamma both fit reasonably well.** The Cullen and Frey graph placed the data point almost exactly on the boundary between these two distributions, and `gamlss` independently selected lognormal — consistent with the heavy right tail observed in the data.

**Lognormal was selected as the final fit.** A formal goodness-of-fit comparison (`gofstat()` in `fitdistrplus`) was used as the tiebreaker between lognormal and gamma:

| Statistic | Lognormal | Gamma | Better fit |
|---|---|---|---|
| Chi-squared | 1.06 | 4.06 | Lognormal |
| Chi-squared p-value | 0.590 | 0.131 | Lognormal |
| Cramér-von Mises | 0.0273 | 0.0820 | Lognormal |
| Anderson-Darling | 0.190 | 0.458 | Lognormal |
| Kolmogorov-Smirnov | 0.102 | 0.163 | Lognormal |
| AIC | 179 | 182 | Lognormal |
| BIC | 181 | 184 | Lognormal |

Lognormal outperformed gamma on every statistic, including the chi-squared p-value, where higher is better. This is a clean, consistent result rather than a mixed signal across tests.

## Project Structure

```
distribution_fitting.R   # Full annotated analysis script
```

The script is split into three parts:

- **Part 1** — Initial visual exploration and distribution detection across the three methods, with narrated reasoning for accepting/rejecting each candidate.
- **Part 2** — Visual comparison of the two remaining candidates (lognormal, gamma) using density comparison and Q-Q comparison plots.
- **Part 3** — Formal goodness-of-fit testing and final distribution selection.

## Limitations

This analysis used a small simulated dataset (n = 21) to validate the distribution-fitting workflow across multiple methods (`simukde`, `gamlss`, `fitdistrplus`). With such a small sample, goodness-of-fit statistics — particularly p-values — are less stable and more sensitive to individual data points, so the lognormal vs. gamma distinction here should be treated as a useful demonstration of method rather than a high-confidence conclusion. Real-world data with larger sample sizes would be needed to draw firmer conclusions.

## Requirements

```r
install.packages(c("tidyverse", "simukde", "dplyr", "gamlss", "fitdistrplus", "actuar", "goftest"))
```

## How to Run

```r
source("distribution_fitting.R")
```

This will generate five plots (`histogram_density.png`, `density_plot.png`, `Cullen and Frey graph.png` ) etc and print summary statistics and goodness-of-fit results to the console.
