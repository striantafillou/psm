function x = addnoise(x_in)

nsamples= length(x_in);

std_noise= 0.1*nanstd(x_in);

x = x_in+std_noise.*randn(nsamples,1);

end