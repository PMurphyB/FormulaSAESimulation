clc, clearvars, clear all

trackDXF = dxf_to_track()

data = readtable("track.xlsx");

disp(data);

% Other constants
aveAcceleration = 16;
aveDeceleration = 16;
maxVelocity = 70;
timeStep = 0.1;

% Constants for turn speed
mu = 0.85;
g = 9.81;

velocity = 0;
time = 0;

% Maybe will use later for position tracking across the track rather than
% just segment
% position = 0;


timeMatrix = [];
accelerationMatrix = [];
velocityMatrix = [];

for i = 1:height(data)
    segment = data(i,:);
    type = segment.Type{1};
    straightLength = segment.Length;
    arcLength = segment.ArcLength;
    radius = segment.Radius;
    %turnDirection = segment.TurnDirection;  % For future stuff

    if strcmp(type, 'Straight')
        position = 0;
        while position < straightLength 

            if velocity < maxVelocity
                velocity = velocity + aveAcceleration * 0.1; % time

                if velocity > maxVelocity
                    velocity = maxVelocity;

                end

            end

            position = position + velocity * 0.1
            time = time + 0.1;

            timeMatrix = [timeMatrix, time]; 
            accelerationMatrix = [accelerationMatrix, aveAcceleration]; % Constant acceleration
            velocityMatrix = [velocityMatrix, velocity]; % Store current velocity

        end


    elseif strcmp(type, 'Curve')
        position = 0;
        % Calculate Braking Distance
        stopDistance = (velocity^2) / (2 * aveDeceleration); % Asked ChatGPT

        if stopDistance < arcLength
            brakeDistance = stopDistance;

        else 
            brakeDistance = arcLength - 10;

        end

        while position < arcLength

            if position >= (arcLength - brakeDistance)

                velocity = velocity - aveDeceleration * 0.1;

                if velocity < 0
                    velocity = 0;

                end
            end

            position = position + velocity * 0.1
            time = time + 0.1;

            timeMatrix = [timeMatrix, time];
            accelerationMatrix = [accelerationMatrix, -aveDeceleration];
            velocityMatrix = [velocityMatrix, velocity]; % Store current velocity

        end
    end
end

time
velocity

figure(1);
plot(timeMatrix,accelerationMatrix,'g');
xlabel("Time (s)");, ylabel("Acceleration");, title("Accerleration vs. Time"), grid on;
xlim([0,timeMatrix(end)]), ylim([-20,20]);

figure(2);
plot(timeMatrix,velocityMatrix,'g');
xlabel("Time (s)");, ylabel("Velocity");, title("Velocity vs. Time"), grid on;
xlim([0,timeMatrix(end)]), ylim([0,70]);