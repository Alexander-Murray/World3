function ldens = lpdfgam(x, a, b)
% log gamma pdf
ldens = -lngam(a) - a*log(b) + (a-1)*log(x) - x/b;
