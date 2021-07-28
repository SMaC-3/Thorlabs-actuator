function [ PosZ Time ] = getpos(dist, vel, acc)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global h;

InitialPos = h.GetPosition_Position(0);

h.SetVelParams(0,0,acc, vel); %(channelID, MinVel, Accn, MaxVel)

h.SetRelMoveDist(0,dist);

tacc = vel/acc; %Time spent accelerating
Dacc = acc*tacc^2/2; %Distance covered during acceleration 
tdec = -vel/-acc; %Time spent deccelerating
Ddec = vel*tdec - acc*tdec^2/2; %Distance covered during decceleration 

Dcon = abs(dist) - (Dacc + Ddec); %Distance covered at constant velocity 

totaltime = tacc + tdec + Dcon/vel; %total time for approach
tiave = 0.0159; %average spacing between time readings
points = ceil(totaltime/tiave) + 5; %total number of measurements required to cover full approach

h.MoveRelative(0,1==0);
    t1 = clock;
    for i=1:points
        Pos(i) = h.GetPosition_Position(0);
        Time(i) = etime(clock,t1);
    end
    
    PosZ = Pos - InitialPos; %Convert to absolute distance 
end

