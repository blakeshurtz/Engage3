 data {
   // Define variables in data
   // Number of level-1 observations (an integer)
   int<lower=0> N_obs;
   // level 1 categorial predictor
   int upc_id[N_obs];
   //Number of Level 1 categorial predictors
   int<lower=0> N_upc;
   // Continuous outcome
   real Price[N_obs];
   // Number of level-2 clusters
   int<lower=0> N_stores;
   // Number of level-3 clusters
   int<lower=0> N_banners;
   // Cluster IDs (for all levels)
   int<lower=1> store_id[N_obs];
   int<lower=1> banner_id[N_obs];
   // Level 3 look up vector for level 2
   int<lower=1> banner_level_lookup[N_stores];
 }

parameters {
  // Population intercept
  real beta_0;

  // Population Slope- a different slope for each factor
  //vector[N_upc] beta_1;

  // Level-1 errors
  real<lower=0> sigma_e0;
  // Note that the subscripts changed between the two_level and 3 level model, not _j represents the 3rd level not the 2nd
  
  // Level-2 random effect
  vector[N_stores] u_0jk;
  real<lower=0> sigma_u0jk;

  // Level-3 random effect
  vector[N_banners] u_0k;
  real<lower=0> sigma_u0k;
}

transformed parameters  {

  // Varying intercepts
  vector[N_stores] beta_0jk;
  vector[N_banners] beta_0k;

  // Level-2- start from the population and work your way down!
  beta_0k = beta_0 + u_0k; //population -> banners

  // Level-3 //banners -> stores
  beta_0jk = beta_0k[banner_level_lookup] + u_0jk;
}

model {
  // Prior part of Bayesian inference

  // Random effects distribution
  u_0k  ~ normal(0, sigma_u0k);
  u_0jk ~ normal(0, sigma_u0jk);

  // Likelihood part of Bayesian inference
   Price ~ normal(beta_0jk[store_id], sigma_e0);
}

generated quantities {
  vector[N_obs] log_lik;
  for (n in 1:N_obs) log_lik[n] = normal_lpdf(Price[n] | beta_0jk[store_id][n], sigma_e0);
}
