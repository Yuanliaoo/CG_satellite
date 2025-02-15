%%
num_orbit = 6;
num_sat_orbit = 5;
num_ground_sat = 6;
capacity_sat = 5; 
capacity_ground = 1; 
computer_capacity = 10;


[sat_position, adj_matrix_sat, adj_matrix_ground, capacity_matrix, demand_matrix, compute_matrix] ...
    = create_constellation(num_orbit, num_sat_orbit, num_ground_sat, capacity_sat, capacity_ground,computer_capacity);

%%

max_hop_sat = 4;
max_hop_ground = 4;

[part_sat_path, part_num_sat_path, part_ground_path, part_num_ground_path] ...
    = initialize_part_path(adj_matrix_sat, adj_matrix_ground, max_hop_sat, max_hop_ground);

[satpath_edges,satpath_source,satpath_terminal] = create_path_sat(part_sat_path, part_num_sat_path, adj_matrix_sat);
[groundpath_edges,groundpath_lastsecond,groundpath_source] = create_path_ground(part_ground_path, part_num_ground_path, adj_matrix_ground);

%% 
obj_weight = [0.5; 0.3; 0.2];

[compute_vol,SatCapCon_dual,GroundCapCon_dual,DemandCon_dual,ComputeCon_dual] ...
    = master_solver(capacity_matrix,demand_matrix,compute_matrix, obj_weight,...
    satpath_edges,satpath_source,satpath_terminal,...
    groundpath_edges,groundpath_lastsecond,groundpath_source);

%% 
[is_satopt,part_sat_path,part_num_sat_path] = ...
    add_sat_column(adj_matrix_sat,max_hop_sat,part_sat_path,part_num_sat_path,...
    SatCapCon_dual,DemandCon_dual,ComputeCon_dual,obj_weight);

[is_groundopt,part_ground_path,part_num_ground_path] = ...
    add_ground_column(adj_matrix_ground,max_hop_ground,part_ground_path,part_num_ground_path,...
    SatCapCon_dual,GroundCapCon_dual,DemandCon_dual,obj_weight);