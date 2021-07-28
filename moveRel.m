function moveRel(relDist, hardLimit)
global h

finalPos = h.GetPosition_Position(0) + relDist;

if finalPos > hardLimit
    msg = 'Error: hard limit exceeded. Glass will break if actuator travels further.';
    error(msg);
else
    h.SetRelMoveDist(0, relDist);
    h.MoveRelative(0,1==0);

end