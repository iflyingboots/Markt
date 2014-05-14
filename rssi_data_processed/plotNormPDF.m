function plotNormPDF(u,s,color)
    mu = u; 
    sigma = s; 
    x = (mu - 5 * sigma) : (sigma / 100) : (mu + 5 * sigma); 
    pdfNormal = normpdf(x, mu, sigma);
    string = 'the maximal pdfNormal is';
    string = sprintf('%s :%d', string,max(pdfNormal));
    disp(string)
    plot(x, pdfNormal/max(pdfNormal),color); 
end