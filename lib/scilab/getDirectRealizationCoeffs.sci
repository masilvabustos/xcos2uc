
function [forward_coeff, feedback_coeff] = getDirectRealizationCoeffs(f)
    
    d = coeff(f.den)
    a = zeros(1, length(d))
    
    for i=1:length(a)
        a(i) = d(length(d)-i+1)
    end
    
    c = coeff(f.num)

    n = length(a) - 1
    m = length(c) - 1
    
    b = zeros(1, length(a))
    
    for k = 0:m
        b(n-m+k+1) = c(m-k+1)
    end

    forward_coeff = zeros(1, m+1)
    feedback_coeff = zeros(1, n+1)
    
    for i = 1:length(forward_coeff)
        forward_coeff(i) = b(i)/a(1)
    end
    
    feedback_coeff(1) = 1/a(1)
    for i = 2:length(feedback_coeff)
        feedback_coeff(i) = -a(i)/a(1)
    end
    
    disp(forward_coeff)
    disp(feedback_coeff)
    
endfunction

