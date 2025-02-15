function [satpath_edges,satpath_source,satpath_terminal] = create_path_sat(sat_path, num_sat_path, adj_matrix_sat)

[num_sat, ~] = size(adj_matrix_sat);

satpath_edges = zeros(num_sat,num_sat, num_sat_path);

satpath_source = zeros(num_sat, num_sat_path);

satpath_terminal = zeros(num_sat, num_sat_path);

path_id = 1;

for source_sat = 1:num_sat
    for terminal_sat = 1:num_sat

        path_ij = sat_path{source_sat, terminal_sat};
        [num_path_ij,~] = size(path_ij);
        
        if num_path_ij > 0
            for s = 1: num_path_ij
                % get one path
                path1 = path_ij{s};

                [~,path_length] = size(path1);
                for q = 1:path_length-1
                    first_node = path1(q);
                    second_node = path1(q+1);
                    satpath_edges(first_node,second_node,path_id) = 1;
                end

                % Update the satpath_source matrix
                satpath_source(source_sat,path_id) = 1;

                % Update the satpath_terminal matrix
                satpath_terminal(terminal_sat,path_id) = 1;
        
                % Update the path_id
                path_id = path_id+1;

            end
        end

    end
end

end

