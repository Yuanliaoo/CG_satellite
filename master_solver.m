function [compute_vol,SatCapCon_dual,GroundCapCon_dual,DemandCon_dual,ComputeCon_dual] ...
    = master_solver(capacity_matrix,demand_matrix,compute_matrix, obj_weight,...
    satpath_edges,satpath_source,satpath_terminal,...
    groundpath_edges,groundpath_lastsecond,groundpath_source)

[num_sat, ~, num_sat_path] = size(satpath_edges);
[~, ~, num_ground_path] = size(groundpath_edges);


% add variables
x_i = sdpvar(num_sat,1);

sat_flow = sdpvar(num_sat_path, 1, 'full');

ground_flow = sdpvar(num_ground_path, 1, 'full');

% add constraints
Con = [];

for i = 1:num_sat
    for j = 1:num_sat
        if capacity_matrix(i+1, j+1) > 0
            satpath_edges_ij =  squeeze(satpath_edges(i,j,:));
            groundpath_edges_ij = squeeze(groundpath_edges(i,j,:));

            if (sum(satpath_edges_ij) >0) || (sum(groundpath_edges_ij) >0)
                Con = [Con,...
                    (satpath_edges_ij' * sat_flow + groundpath_edges_ij' * ground_flow...
                    <= capacity_matrix(i+1, j+1))...
                    :['SatCapCon' num2str(i) '_' num2str(j)]];
            end
        end
    end
end

for i = 1:num_sat
    if capacity_matrix(i, 1) > 0
        groundpath_lastsecond_i = squeeze(groundpath_lastsecond(i,:));
        if sum(groundpath_lastsecond_i) > 0
            Con = [Con,...
                (groundpath_lastsecond_i * ground_flow <= capacity_matrix(i, 1))...
                :['GroundCapCon' num2str(i)]];
        end
    end
end

Con = [Con, ...
    (x_i + satpath_source * sat_flow + groundpath_source * ground_flow...
    <= demand_matrix):'DemandCon'];

Con = [Con, ...
    (x_i + satpath_terminal * sat_flow <= compute_matrix):'ComputeCon'];

Con = [Con, x_i >= 0, sat_flow >= 0, ground_flow >= 0];

Obj = -1*(obj_weight(1) * sum(x_i)...
    + obj_weight(2) * sum(sat_flow)...
    + obj_weight(3) * sum(ground_flow));

ops = sdpsettings('solver', 'cplex', 'verbose', 0,'savesolveroutput',1);

output=solvesdp(Con,Obj,ops);

SatCapCon_dual = zeros(num_sat, num_sat);
GroundCapCon_dual = zeros(num_sat, 1);

for i = 1:num_sat
    for j = 1:num_sat
        if capacity_matrix(i+1, j+1) > 0
            if (sum(squeeze(satpath_edges(i,j,:))) >0) || (sum(squeeze(groundpath_edges(i,j,:))) >0)
                SatCapCon_dual(i,j) = dual(Con(['SatCapCon' num2str(i) '_' num2str(j)]));
            end
        end
    end
end

for i = 1:num_sat
    if capacity_matrix(i, 1) > 0
        if sum(squeeze(groundpath_lastsecond(i,:))) > 0
            GroundCapCon_dual(i) = dual(Con(['GroundCapCon' num2str(i)]));
        end
    end
end

DemandCon_dual = dual(Con('DemandCon'));

ComputeCon_dual = dual(Con('ComputeCon'));


compute_vol = zeros(3,1);
compute_vol(1) = sum(value(x_i));
compute_vol(2) = sum(value(sat_flow));
compute_vol(3) = sum(value(ground_flow));

end

