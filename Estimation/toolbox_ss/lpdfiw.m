function ldens = lpdfiw(G, H, nu)
% log inverse wishart

    m = size(G,1);
  kap = 0;

for i=1:1:m
    kap = kap + lngam(0.5*(nu+1-i));
end

  kap = -kap -0.5*nu*m*log(2) - 0.25*m*(m-1)*log(pi);
ldens = kap + 0.5*nu*log(det(H)) - 0.5*(nu+m+1)*log(det(G)) - 0.5*sum(diag(G\H));
