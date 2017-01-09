function d = standardized_difference(x, y)
% Calculate standardized difference for variables x and y
% Reference Austin (2009) Balancing measures ...



d = (mean(x)-mean(y))./sqrt((var(x)+var(y))/2);
end