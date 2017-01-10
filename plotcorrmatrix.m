function ah =plotcorrmatrix(A, varnames)

[~, nVars] = size(A);

ah= nan(nVars);
c = corr(A);
for i=1:nVars;
    for j = i:nVars;
        ah(i, j) = subplot(nVars, nVars, sub2ind([nVars nVars], i, j));
        if i==j
            ax(i, j) =histogram(A(:, i));set(ah(i, j), 'ytick', [], 'xtick', []);
        else
            ax(i, j) =scatter(A(:, i), A(:, j), '.');set(ah(i, j), 'ytick', [], 'xtick', []);
            title(sprintf('%.3f', c(i, j)));
        end
        if i==1; ylabel(varnames{j},'interpreter', 'none');end
        if j==nVars; xlabel(varnames{i}, 'interpreter', 'none');end
       
    end
end
      

end