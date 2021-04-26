function [planeNormals] = PlanesMBToCartesianNormals(planesRefmb,a1,a2,~,a4)
	% INPUT:
	%       planesRefmb: matrix of MB indices (hkil) describing planes -- size (Q,4) for Q slip systems
	%                     NOTE: a size (Q,3) matrix of (hkl) Miller indices will also work
	%       a1,a2,a4: HCP lattice vectors -- each size (1,3)
    %                     NOTE: a1,a2,a4 (a3 omitted) must be linearly dependent!
	% OUTPUT: 
	%		planeNormals: matrix of unit normal vectors of the planes generated by the corresponding MB indices -- size (Q,3)
	
	planeNormals = zeros(size(planesRefmb,1),3);
	
	for i = 1:size(planesRefmb,1)
		
		indices = planesRefmb(i,:); % MB indices describing a plane in HCP
		
		% Notice that (a1,a2,a4) is the chosen linearly independent HCP basis:
		unitNormalVec = IndicesMBToCartesianNormal(indices,a1,a2,a4);
		
		planeNormals(i,:) = unitNormalVec; % Unit normal vector in cartesian coordinates
	end
end