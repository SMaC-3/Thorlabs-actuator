

Time = [];
Pos = [];

InitialPos = h.GetPosition_Position(0);

acc = 1;
maxVel = .5;
dis = 2.1;

h.SetVelParams(0,0,acc,maxVel); %(channelID, MinVel, Accn, MaxVel)

finalPos = h.GetPosition_Position(0) + dis;

if finalPos > hardLimit
    msg = 'Error: hard limit exceeded. Glass will break if actuator travels further.';
    error(msg);
end

h.SetRelMoveDist(0,dis);
h.MoveRelative(0,1==0);

t1 = clock;
t2 = dis/maxVel;
i = 1;
    while etime(clock, t1)< t2 + 1
        Pos(i) = h.GetPosition_Position(0);
        Time(i) = etime(clock,t1);
        i = i + 1;
    end
    
    PosZ = Pos - InitialPos;
    
    for i = 1:length(PosZ)-1
    Vel(i) = (PosZ(i+1)-PosZ(i))/(Time(i+1)-Time(i));
    end
    
Vel(length(Time)) = NaN;    
prompt = 'Would you like to save the output Y/N [Y]: ';
saveOpt = input(prompt,'s'); 

if isempty(saveOpt)
    saveOpt = 'Y';
end

if saveOpt == 'Y'
    % Pos, PosZ, Time, Vel, t1
    name = input('Please provide a filename: ','s');
    type = '.txt';
    save(fullfile('PhD','mat_format',name),'Pos', 'PosZ', 'Time', 'Vel', 't1');
    T_move = table(round(Pos.',5), round(PosZ.',5), round(Time.',5),round(Vel.',5)...
        ,'VariableNames',{'Pos','Posz','Time','Vel'});
    writetable(T_move, fullfile('PhD',strcat(name,type)), 'Delimiter','\t');
end
    