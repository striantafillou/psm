clear;close all;
load('features', 'extendedFeatures', 'allExtendedFeatures');load subjects;
nSubjects = length(subjects);
nSamples = zeros(nSubjects, 1);
figure;hold all;
betas =nan(nSubjects,2);
for iSub=1:nSubjects
    if isempty(extendedFeatures{iSub});continue;end
    [nanRows,~] = find(isnan(extendedFeatures{iSub}{:, :}));extendedFeatures{iSub}(nanRows, :)= []; 
    if isempty(extendedFeatures{iSub});continue;end
    nSamples(iSub)= height(extendedFeatures{iSub});
    if nSamples(iSub)<20
        continue;
    end
    y = extendedFeatures{iSub}{:, 'mood'}; 
    x = extendedFeatures{iSub}{:, 'sleep_quality'}; 
    scatter(x, y, '.'); xlim([-1 10]); ylim([-1 10]);
    b = regress(y, [x ones(nSamples(iSub),1)]);
    refline(b(1), b(2));
    betas(iSub, :)=b;
end
        
%%