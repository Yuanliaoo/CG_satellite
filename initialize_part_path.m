function [sat_path, num_sat_path, ground_path, num_ground_path] ...
    = initialize_part_path(adj_matrix_sat, adj_matrix_ground, max_hop_sat, max_hop_ground)
[num_sat, ~] = size(adj_matrix_sat);

sat_graph = graph(adj_matrix_sat);

sat_path = cell(num_sat, num_sat);
num_sat_path = 0;

for source_sat = 1: num_sat
    for terminal_sat = 1: num_sat
        if source_sat ~= terminal_sat

            path_ij = allpaths(sat_graph,source_sat,terminal_sat,...
                'MaxPathLength',max_hop_sat,'MaxNumPaths',1);
            sat_path{source_sat, terminal_sat} = path_ij;

            [num_path_ij,~] = size(path_ij);
            num_sat_path = num_sat_path + num_path_ij;
        end
    end
end

ground_graph = graph(adj_matrix_ground);

ground_path = cell(num_sat + 1, 1);
num_ground_path = 0;

for source_ground = 2: num_sat + 1

    path_ij = allpaths(ground_graph,source_ground, 1,...
        'MaxPathLength',max_hop_ground,'MaxNumPaths',1);
    ground_path{source_ground} = path_ij;


    [num_path_ij,~] = size(path_ij);
    num_ground_path = num_ground_path + num_path_ij;
end

end

