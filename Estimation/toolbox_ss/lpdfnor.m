function ldens = lpdfnor(x, a, b)
% log normal pdf
ldens = -0.5*log(2*pi) - log(b) - 0.5*(x-a)^2/b^2;