function [is_groundopt,part_ground_path,part_num_ground_path] = ...
    add_ground_column(adj_matrix_ground,max_hop_ground,part_ground_path,part_num_ground_path,...
    SatCapCon_dual,GroundCapCon_dual,DemandCon_dual,obj_weight)


[num_sat_ground, ~] = size(adj_matrix_ground);
num_sat = num_sat_ground - 1;

graph_map = graph(adj_matrix_ground);

is_groundopt = 1;

for source_sat = 2: num_sat+1

    all_path_i = allpaths(graph_map,source_sat,1,'MaxPathLength',max_hop_ground);

    [num_path_i, ~] = size(all_path_i);
    
    if num_path_i >= 1
        shortest_length = 10^9;
        shortest_path = {};

        for path_id = 1: num_path_i
            
            path__i_j = all_path_i{path_id};
            sum_dual = 0;
            [~, path_length] = size(path__i_j);

            if path_length > 2
                for q = 1:path_length -2
                    first_node = path__i_j(q) - 1;
                    second_node = path__i_j(q+1) - 1;
                    sum_dual = sum_dual + ...
                        SatCapCon_dual(first_node,second_node);
                end
            end
            
            sum_dual = sum_dual ...
                + DemandCon_dual(path__i_j(1) - 1)...
                + GroundCapCon_dual(path__i_j(path_length-1) - 1);
            
            % Update the shortest path
            if sum_dual <= shortest_length
                shortest_length = sum_dual;
                shortest_path = path__i_j;
            end

        end
        
        % check if this path violates the dual constraints
        if shortest_length < obj_weight(3)
            part_ground_path{source_sat, 1} ...
                = [part_ground_path{source_sat, 1} ; {shortest_path}];
            is_groundopt = 0;
            part_num_ground_path = part_num_ground_path + 1;
        end
    end 

end


end

