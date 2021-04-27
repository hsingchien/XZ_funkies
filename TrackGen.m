function [traj,wall_dists] = TrackGen(range,start_p,len,speed_distr)

x_r = range([1,2]);
y_r = range([3,4]);

traj = zeros(len,2);
traj(1,:) = start_p;
wall_dists = []
for i = 2:len
   
    this_speed = speed_distr(randi(length(speed_distr)));
    cur_pos = traj(i-1,:);
    cur_x = cur_pos(1);
    cur_y = cur_pos(2);
    speed_range = [];
    while isempty(speed_range)
    % get a random direction
        direction = 2*pi*rand();  
        if direction >= 0 & direction <pi/2
            wall_dist = min((cur_y-y_r(1))/sin(direction), (x_r(2)-cur_x)/cos(direction));
        elseif direction >= pi/2 & direction <pi
            wall_dist = min((cur_x-x_r(1))/abs(cos(direction)), (cur_y-y_r(1))/sin(direction));
        elseif direction >=pi & direction < 3/2*pi
            wall_dist = min((cur_x-x_r(1))/abs(cos(direction)), (y_r(2)-cur_y)/abs(sin(direction)));
        else
            wall_dist = min((x_r(2)-cur_x)/cos(direction), (y_r(2)-cur_y)/abs(sin(direction)));
        end
        wall_dists = [wall_dists;wall_dist];
        % get speed
        speed_range = speed_distr(speed_distr<=wall_dist);
    end
    this_speed = speed_range(randi(length(speed_range)));
    
    x_delta = this_speed * cos(direction);
    y_delta = -this_speed * sin(direction);
        
    traj(i,:) = [cur_x + x_delta, cur_y + y_delta];
    
    
end





end

