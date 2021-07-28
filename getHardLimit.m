function hardLimit = getHardLimit(gap)
global h

if nargin < 1
    gap = 0.1;
end

hardLimit = h.GetPosition_Position(0) + gap;

disp(strcat('hard limit has been set to',{' '}, sprintf('%f',hardLimit)))

end