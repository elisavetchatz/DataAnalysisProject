function plot_histogram_qq(data, lambda, coil_code)
    % Ιστόγραμμα για τα δεδομένα του πηνίου
    figure;
    
    % Ιστόγραμμα για τα δεδομένα του CoilCode
    subplot(1,2,1); 
    histogram(data, 'Normalization', 'pdf'); 
    hold on;
    x = linspace(min(data), max(data), 100);
    y = exppdf(x, 1/lambda);
    plot(x, y, 'r-', 'LineWidth', 2);
    title(['Histogram for Coil Code ' num2str(coil_code)]);
    xlabel('ED Duration');
    ylabel('Probability Density');
    
    % Q-Q plot για τα δεδομένα σε σχέση με την εκθετική κατανομή
    subplot(1,2,2); 
    qqplot(data, makedist('Exponential', 'mu', 1/lambda));
    title(['Q-Q Plot for Coil Code ' num2str(coil_code)]);
end
