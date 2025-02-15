function [is_satopt,part_sat_path,part_num_sat_path] = ...
    add_sat_column(adj_matrix_sat,max_hop_sat,part_sat_path,part_num_sat_path,...
    SatCapCon_dual,DemandCon_dual,ComputeCon_dual,obj_weight)

[num_sat, ~] = size(adj_matrix_sat);
graph_map = graph(adj_matrix_sat);

is_satopt = 1;

for source_sat = 1: num_sat
    for terminal_sat = 1: num_sat
        if source_sat ~= terminal_sat

            all_path_i = allpaths(graph_map,source_sat,terminal_sat,'MaxPathLength',max_hop_sat);

            [num_path_i, ~] = size(all_path_i);
            
            if num_path_i >= 1
                shortest_length = 10^9;
                shortest_path = {};

                for path_id = 1: num_path_i
                    
                    path__i_j = all_path_i{path_id};
                    sum_dual = 0;
                    [~, path_length] = size(path__i_j);

                    for q = 1:path_length -1
                        first_node = path__i_j(q);
                        second_node = path__i_j(q+1);
                        sum_dual = sum_dual + ...
                            SatCapCon_dual(first_node,second_node);
                    end
                    
                    sum_dual = sum_dual ...
                        + DemandCon_dual(path__i_j(1))...
                        + ComputeCon_dual(path__i_j(path_length));
                    
                    % Update the shortest path
                    if sum_dual <= shortest_length
                        shortest_length = sum_dual;
                        shortest_path = path__i_j;
                    end

                end
                
                % check if this path violates the dual constraints
                if shortest_length < obj_weight(2)
                    part_sat_path{source_sat, terminal_sat} ...
                        = [part_sat_path{source_sat, terminal_sat} ; {shortest_path}];
                    is_satopt = 0;
                    part_num_sat_path = part_num_sat_path + 1;
                end
            end 

        end
    end
end


end

