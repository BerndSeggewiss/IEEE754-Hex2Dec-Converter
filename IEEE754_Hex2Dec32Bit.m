% Calculate decimal representation from a 32-digit (single precision)
% binary number according to specification of IEEE754.

% The input is a string consisting of a valid number of hexadecimal 
% characters (see examples).

% Formula symbols:
% exp: Exponent
% m: mantissa
% s: sign
% r: number bits of exponent
% p: number bits of mantissa
% b: bias

% Examples:
% Exp = 0; m = 0: 
% out = IEEE754_Hex2Dec32Bit("00000000") returns 0
% out = IEEE754_Hex2Dec32Bit("80000000") returns 0
% Exp = 0; m > 0 (denormalised number):
% out = IEEE754_Hex2Dec32Bit("007fffff") returns 1.175494210692441e-38
% 0 < exp < 2^r-1; m >= 0 (normalised number):
% out = IEEE754_Hex2Dec32Bit("40ffffff") returns 7.999999523162842
% exp = 2^r-1; m = 0 (+/-infinity):
% out = IEEE754_Hex2Dec32Bit("ff800000") returns -Inf
% out = IEEE754_Hex2Dec32Bit("7f800000") returns Inf
% exp = 2^r-1; m > 0 (not a number)
% out = IEEE754_Hex2Dec32Bit("ffc00000") returns NaN
% out = IEEE754_Hex2Dec32Bit("ffc00001") returns NaN

% Written by Bernd Seggewiß
% Published 17/08/23
% Version 1.0.0

function out = IEEE754_Hex2Dec32Bit(hexString)
    if isstring(hexString)
        hexString = hexString{1};
    end
    binVal = hexToBinaryVector(hexString);
    initBinaryVector = (zeros(32,1))';
    digits = numel(binVal);
    initBinaryVector(end-(digits-1):end) = binVal;
    binVal = initBinaryVector;
    data.s = binVal(1);
    data.exp = binVal(2:9);
    data.m = binVal(10:end);
    [s, exp, m] = calcVariables(data);
    out = calcValue(s, exp, m);
end

function [s, exp, m] = calcVariables(data)
    if data.s == 1
        s = -1;
    elseif data.s == 0
        s = +1; 
    end
    [strVal1, strVal2] = deal(num2str(data.exp), num2str(data.m));
    strVal1(isspace(strVal1)) = '';
    strVal2(isspace(strVal2)) = '';
    [exp, m] = deal(bin2dec(strVal1), bin2dec(strVal2));
end

function val = calcValue(s, exp, m)
    format long
    r = 8;
    p = 23;
    b = 127;
    if exp == 0 && m == 0
        val = (s)^s*0;
    elseif exp == 0 && m > 0
        val = (s)^s * m/2^p * 2^(1-b);
    elseif (0 < exp) && (exp < 2^r-1)
        % 0 < exp < 2^r-1
        if m >= 0
            val = (s)^s * (1+m/2^p) * 2^(exp-b);
        end
    elseif (exp == 2^r-1) && (m == 0)
        val = s*inf;
    elseif (exp == 2^r-1) && (m > 0)
        val = nan;
    end 
end



