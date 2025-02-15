function [sat_position, adj_matrix_sat, adj_matrix_ground, capacity_matrix, demand_matrix, compute_matrix] ...
    = create_constellation(num_orbit, num_sat_orbit, num_ground_sat, capacity_sat, capacity_ground,computer_capacity)

num_sat = num_orbit * num_sat_orbit;


sat_position = zeros(num_sat, 3);
sat_position(:, 1) = 1: num_sat;


sat_id = 1;

for orbit_id = 1:num_orbit
    for sat_orbit_id = 1:num_sat_orbit

        sat_position(sat_id, 2) = orbit_id;

        sat_position(sat_id, 3) = sat_orbit_id;

        sat_id =  sat_id + 1;
    end
end
%% 生成adj_matrix_sat和adj_matrix_ground

% 初始化
adj_matrix_sat = zeros(num_sat, num_sat);
adj_matrix_ground = zeros(num_sat + 1, num_sat + 1);

for sat_id_1 = 1: num_sat
    for sat_id_2 = 1: num_sat
        
        orbit_id_1 = sat_position(sat_id_1, 2);
        sat_orbit_id_1 = sat_position(sat_id_1, 3);
        orbit_id_2 = sat_position(sat_id_2, 2);
        sat_orbit_id_2 = sat_position(sat_id_2, 3);

        if orbit_id_1 == orbit_id_2
            if (abs(sat_orbit_id_1 - sat_orbit_id_2) == 1) || ...
                    (sat_orbit_id_1 == 1 && sat_orbit_id_2 == num_sat_orbit) || ...
                    (sat_orbit_id_1 == num_sat_orbit && sat_orbit_id_2 == 1)
                adj_matrix_sat(sat_id_1, sat_id_2) = 1; adj_matrix_sat(sat_id_2, sat_id_1) = 1;
                adj_matrix_ground(sat_id_1+1, sat_id_2+1) = 1; adj_matrix_ground(sat_id_2+1, sat_id_1+1) = 1;
            end
        end

        if sat_orbit_id_1 == sat_orbit_id_2
            if (abs(orbit_id_1 - orbit_id_2) == 1) || ...
                    (orbit_id_1 == 1 && orbit_id_2 == num_orbit) || ...
                    (orbit_id_1 == num_orbit && orbit_id_2 == 1)
                adj_matrix_sat(sat_id_1, sat_id_2) = 1; adj_matrix_sat(sat_id_2, sat_id_1) = 1;
                adj_matrix_ground(sat_id_1+1, sat_id_2+1) = 1; adj_matrix_ground(sat_id_2+1, sat_id_1+1) = 1;

            end
        end

    end
end

adj_matrix_ground(1, 2: num_ground_sat + 1) = 1;
adj_matrix_ground(2: num_ground_sat + 1, 1) = 1;

capacity_matrix = zeros(num_sat + 1, num_sat + 1);

capacity_matrix(1, 2: num_ground_sat + 1) = capacity_ground;
capacity_matrix(2: num_ground_sat + 1, 1) = capacity_ground;

for sat_id_1 = 2: num_sat + 1
    for sat_id_2 = 2: num_sat + 1
        if adj_matrix_ground(sat_id_1, sat_id_2) == 1
            capacity_matrix(sat_id_1, sat_id_2) = capacity_sat;
        end
    end
end

com_avg = 20; %200;
com_dev = 1.3;
com_mu = log(com_avg)-0.5*com_dev^2;
demand_matrix = lognrnd(com_mu,com_dev,num_sat,1);

compute_matrix = computer_capacity * ones(num_sat,1);
end
