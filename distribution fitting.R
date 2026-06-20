library(tidyverse) # data manipulation, and visualization
library(simukde) # To scan and name distribution
library(dplyr) # data frame manipulattion
library(gamlss)
library(fitdistrplus)
library(actuar)
library(goftest)
# Part 1: Finding the distribution of data using a histogram & kernel density estimate

example <- c(0.2,03,0.8,6,5,7,48,25,14,0.369,258,54,2,3,4,58,7,101,25,9,32)
hist(example, breaks = 30, freq = FALSE, col = "red")
lines(density(example),col="yellow",lw=1.8) #density(x)~ Calculates a kernel density estimate — essentially a smoothed version of the histogram, computed as a list of x/y coordinates

#smooth distribution curve of the data
plot(density(example))

#determining name of the distribution of data
best_fit<- find_best_fit(example) # using ~ simulkde
best_model <- fitDist(example, type = "realplus") # using ~ gamIss
Name_model <- descdist(example,boot = 100) # using~ fitdistplus
  
#Summary
des_stats <- summary(example)
print(des_stats)
summary_table <- data.frame(min= min(example),
                            Q1= quantile(example,0.25),
                            median=median(example),
                            mean=mean(example),
                            Q3= quantile(example,0.75),
                            max=max(example))

#  Chart 1: Histogram + density line 
png("histogram_density.png", width = 800, height = 600, res = 150)
hist(example, breaks = 30, freq = FALSE, col = "red")
lines(density(example), col = "yellow", lw = 1.8)
dev.off()

#  Chart 2: Standalone density plot
png("density_plot.png", width = 800, height = 600, res = 150)
plot(density(example))
dev.off()

#  Chart 3: Cullen and Frey graph (descdist) 
png("descdist_plot.png", width = 800, height = 600, res = 150)
Name_model <- descdist(example, boot = 100)
dev.off()

# The data distribution has a heavy tails (high kurtosis≈ 15.41 and high skewness²≈ 11.05)
# Since the simukde finds the best fit for the distribution to be a Cauchy distribution, with undefined mean and variance. I reject this distribution because the data is highly skewed and has a high kurtosis.
# Limitation of simukde that lead to the rejection;KDE-based methods like simulkde are sensitive to extreme/outlying values in small samples, which can produce spurious heavy-tail distribution matches like Cauchy.
#That leaves the gamIss that determined that the best fit of the distribution of the data was a lognormal distribution, this aligns well with the heavy tails identified.
#The fitdistplus;Cullen and Frey graph agrees with the gamIss, and shows that data closely follows either a lognormal or gamma distribution
# Conclusion this data can be model with either a lognormal or a gamma distribution.

# Choosing between the two distributions that perfectly represent the data.
#  By doing a comparison between gamma and lognormal and hypothesis testing

# Part 2:Comparison analysis using density comparison plot & quantile-quantile comparison plot
fit_lnorm <- fitdist(example,"lnorm")
fit_gamma <- fitdist(example,"gamma")
results <- denscomp(list(fit_lnorm,fit_gamna),
                    fitcol = c("red","purple"),
                    legendtext = c("Lognormal", "Gamma"))
 # The verdict still stands even with the density comparison plot, both distributions fit the data very well.

results_02 <- qqcomp(list(fit_lnorm,fit_gamna),
                     fitcol = c("red","purple"),
                     legendtext = c("Lognormal", "Gamma"))
# qqcomp results show that both distributions have similar tail behavior (both are equally close to the 45°diagonal line).
# There the data can be modeled with a lognormal or gamma distribution.

# Part 3: Goodness_of_Fit Statistics
GoF_tests <- gofstat(list(fit_lnorm,fit_gamna))
 
#     Interpreting the results
#Chi-squared: 1.06 (lognormal) vs 4.06 (gamma), p-values 0.590 vs 0.131. Lognormal has a much higher p-value — strong support,while gamma's 0.131 is getting uncomfortably close to rejecting at the 0.10 level.
#Cramér-von Mises (CvM): 0.0273 vs 0.0820 — lognormal is lower, meaning a better fit. Roughly 3x better.
#Anderson-Darling (AD): 0.190 vs 0.458 — same story, lognormal is noticeably lower (AD is especially sensitive to tail fit, which matters a lot given how heavy-tailed the data looked in the Cullen-Frey plot).
#Kolmogorov-Smirnov (KS): 0.102 vs 0.163 — lognormal again lower.
#AIC: 179 vs 182. BIC: 181 vs 184. Lognormal wins both, though the gap (ΔAIC = 3, ΔBIC = 3) is moderate, not overwhelming — by the usual rule of thumb, a ΔAIC of 2–4 means there's still some support for the second model, while >10 would mean the worse model is essentially ruled out.

# Final conclusion based on the Goodness-of-Fit statistics as the final decider of which distribution to pick between lnorm and gamma.
# Since the gofstat results show that lnorm outperforms the gamma, I can confidently pick the lnorm as the overall best fit of the data.