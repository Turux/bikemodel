function [ sem ] = sem( data )
%SEM Summary of this function goes here
%   Detailed explanation goes here

sem = std(data)/sqrt(length(data));

end

