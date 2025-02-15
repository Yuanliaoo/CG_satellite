function [groundpath_edges,groundpath_lastsecond,groundpath_source] = create_path_ground(ground_path, num_ground_path, adj_matrix_ground)

[num_sat_ground, ~] = size(adj_matrix_ground);
num_sat = num_sat_ground - 1;

groundpath_edges = zeros(num_sat, num_sat, num_ground_path);

groundpath_lastsecond = zeros(num_sat, num_ground_path);

groundpath_source = zeros(num_sat, num_ground_path);

path_id = 1;

for source_sat = 2:num_sat + 1

    path_ij = ground_path{source_sat};
    [num_path_ij,~] = size(path_ij);
    
    if num_path_ij > 0
        for s = 1: num_path_ij
            % get one path
            path1 = path_ij{s};

            % Update the path_edges matrix
            [~,path_length] = size(path1);
            
            if path_length > 2
                for q = 1:path_length-2
                    first_node = path1(q);
                    second_node = path1(q+1);

                    groundpath_edges(first_node-1,second_node-1,path_id) = 1;
                end
            end

            % Update the groundpath_source matrix
            groundpath_source(source_sat-1,path_id) = 1;

            % Update the groundpath_lastsecond matrix
            lastsecond_sat_id = path1(path_length-1);
            groundpath_lastsecond(lastsecond_sat_id-1,path_id) = 1;
    
            % Update the path_id
            path_id = path_id+1;

        end
    end

end

end

