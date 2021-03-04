% Results in strain-stress
% Stress := load/area = Fsim/area of cantilever face
% Strain := displacement/length = Usim/cantilever length
clear all;
close all;
CRYSTAL_STRUCTURE = 'fcc';

slipPlanes = [
        1.0 1.0 1.0;
        1.0 1.0 1.0;
        1.0 1.0 1.0;
        -1.0 1.0 1.0;
        -1.0 1.0 1.0;
        -1.0 1.0 1.0;
        1.0 -1.0 1.0;
        1.0 -1.0 1.0;
        1.0 -1.0 1.0;
        1.0 1.0 -1.0;
        1.0 1.0 -1.0;
        1.0 1.0 -1.0
        ];
bVec = [
    1.0 -1.0 0.0;
    1.0 0.0 -1.0;
    0.0 1.0 -1.0;
    1.0 1.0 0.0;
    1.0 0.0 1.0;
    0.0 1.0 -1.0;
    1.0 1.0 0.0;
    0.0 1.0 1.0;
    1.0 0.0 -1.0;
    1.0 0.0 1.0;
    0.0 1.0 1.0;
    1.0 -1.0 0.0
    ];

% Values from https://www.azom.com/properties.aspx?ArticleID=2193
% Nickel lattice parameter: 3.499 Angstroms
amag = 3.499 * 1e-4; % microns * burgers vector
% Nickel shear modulus: 72 - 86 GPa
mumag = 79e3; % MPa
MU = 1.0;
% Nickel poisson's ratio 0.305 - 0.315.
NU = 0.31;

% x = <100>, y = <010>, z = <001>
dz = 8.711 / amag; % 8.711 microns
dx = 3 * dz;
dy = dz;
mx = 30;
my = 10;
mz = 10;

vertices = [0, 0, 0; ...
            dx, 0, 0; ...
            0, dy, 0; ...
            dx, dy, 0; ...
            0, 0, dz; ...
            dx, 0, dz; ...
            0, dy, dz; ...
            dx, dy, dz];
% u_dot = [m]/MPa, u_dot_real = [m]/[s]
% mumag*1e6 converts the meters to micrometers in the units.
% The experimental displacement rate is 5 nm = 5e-3 micrometers.
% The cantilever is dx micrometers long.
timeUnit = 5e-3*(mumag*1e6);%/dx;
u_dot = 10*dx/timeUnit; 
% u_dot = 5e-3;
% u_dot = dx/mumag;

% This is the proper plotting function.
% plot(Usim(1:curstep-1)/mumag/1e6,Fsim(1:curstep-1)*amag^2*mumag/1e6/1e6)
% This is the simulation time in seconds
% simTime/timeUnit
% plotArgs = struct("factDisp", 1/mumag/1e6, "factForce", 1/1e12);
plotArgs = struct("factDisp", amag, "factForce", amag^2*mumag);
% dt_real = dt_ddlab/(mumag*1e6);

% u_dot = 5e-3;
% u_dot = 10;
sign_u_dot = 1;
loading = @displacementControlMicropillarTensile;
simType = @micropillarTensile;

run fccLoops
prismbVec(:, :) = prismbVec(:, :) / max(abs(prismbVec(1, :)));
prismbVec(:, :) = prismbVec(:, :) * norm(prismbVec(1, :));
segLen = 0.1 / amag;
lmin = 0.1 / amag;
lmax = 0.4 / amag;

a = lmin/20;
rann = 2*a;%lmin/2;
rntol = 3*lmin^2;
rmax = 3*lmin^2;%lmin/2;



xmin = 0.1*dx;
xmax = 0.9*dx;
ymin = 0.1*dy;
ymax = 0.9*dy;
zmin = 0.1*dz;
zmax = 0.9*dz;

% distRange = [xmin ymin zmin; xmax ymax zmax];
% displacement = distRange(1, :) + (distRange(2, :) - distRange(1, :)) .* rand(12, 3);
% links = [];
% rn = [];
% for i = 1:12
%     idx = (i-1)*8;
%     links = [links; (prismLinks((1:8)+idx, :) + idx) prismbVec((1:8)+idx, :) prismSlipPlane((1:8)+idx, :)];
%     displacedCoord = prismCoord((1:8)+idx, :)*segLen + displacement(i, :);
%     rn = [rn; displacedCoord [0;7;7;7;0;7;7;7]];
% end



idxs = 1 + [0; 3; 6; 1; 4; 8; 9; 11];%; 0; 3; 6];
lenIdxs = size(idxs,1);

activeRatio = lenIdxs/12;
totalDlnDensity = dz*dy*10*amag^2; % Dln per micron
activeDlnDensity = totalDlnDensity * activeRatio;
intersectPerSource = 4;
numSources = activeDlnDensity / intersectPerSource;
volumePerSource = (2*segLen)^3;
volumeSources = numSources * volumePerSource;

n = ceil(numSources/8);

distRange = [xmin ymin zmin; xmax ymax zmax];
displacement = distRange(1, :) + (distRange(2, :) - distRange(1, :)) .* rand(n*lenIdxs, 3);
links = [];
rn = [];

for j = 1:n
    for i = 1:lenIdxs
        idx = (i-1)*8 + (j-1)*8*lenIdxs;
        idx2 = (idxs(i)-1)*8;
        links = [links; (prismLinks((1:8)+idx2, :) + idx) prismbVec((1:8)+idx2, :) prismSlipPlane((1:8)+idx2, :)];
        displacedCoord = prismCoord((1:8)+idx2, :)*segLen + displacement(i + (j-1)*lenIdxs, :);
        rn = [rn; displacedCoord [0;7;7;7;0;7;7;7]];
    end
end



% xmin = 0.2*dx;
% xmax = 0.2*dx;
% ymin = 0.5*dy;
% ymax = 0.5*dy;
% zmin = 0.5*dz;
% zmax = 0.5*dz;
% distRange = [xmin ymin zmin; xmax ymax zmax];
% displacement = distRange(1, :) + (distRange(2, :) - distRange(1, :)) .* rand(12, 3);
% links = [];
% rn = [];
% % k = 1, 2 (high loading rate), 3 (low loading rate), 4, 5, 6, 7, 8, 9, 10, 11, 12 move for y < 0.5 dy
% k = 11*8;
% for i = 1:1
%     idx = (i-1)*8;
%     links = [links; (prismLinks((1:8) + k, :) + idx) prismbVec((1:8) + k, :) prismSlipPlane((1:8) + k, :)];
%     displacedCoord = prismCoord((1:8) + k, :)*segLen + displacement(i, :);
%     rn = [rn; displacedCoord [0;7;7;7;0;7;7;7]];
% end

% k = 9 gets activated after displacement of 1.5
% k = 1, 4, 8, 11 get activated after displacement of 2.5
% k = 0, 3, 6 get activated after displacement of 3
% k = 2, 5 get activated after displacement of 20
% k = 7, 10 gets activated after displacement of 25


% % for i = 1:12
% %     idx = (i-1)*8;
% %     links = [links; (shearLinks((1:8)+idx, :) + idx) shearbVec((1:8)+idx, :) shearSlipPlane((1:8)+idx, :)];
% %     displacedCoord = shearCoord((1:8)+idx, :)*segLen + displacement(i, :);
% %     rn = [rn; displacedCoord [0;7;0;7;0;7;0;7]];
% % end
% % displacedCoord(:, 2) = displacedCoord(:, 2) + -6*segLen;


plotnodes(rn,links,dx,vertices);
dt0 = timeUnit;
totalSimTime = timeUnit*1e4;
mobility = @mobfcc0;
saveFreq = 100;
plotFreq = 100;

plotFlags = struct('nodes', true, 'secondary', true);

% Pa s b^(-1)
Bcoeff = struct('screw', 1, 'edge', 1, 'climb', 1e6, 'line', 1e-4);

% lmin = 0.2/amag;
% lmax = 0.4/amag;
% rann = lmin;
% u_dot = dx/timeUnit;
calculateTractions = @calculateAnalyticTractions;
% calculateTractions = @calculateNumericTractions;


% CUDA_flag = true;
% para_scheme = 1;













% % % u_dot = 0.01;
% % % 
% % % amag=sqrt(2)/2*amag;
% % % maxconnections=4; 
% lmax =0.1/amag;
% lmin = 0.04/amag;
% areamin=lmin*lmin*sin(60/180*pi)*0.5; 
% areamax=20*areamin; 
% % % doremesh=1; %flat set to 0 or 1 that turns the remesh functions off or on
% % % docollision=1; %flat set to 0 or 1 that turns collision detection off or on
% % % doseparation=1; %flat set to 0 or 1 that turns splitting algorithm for highly connected node off or on
% % % dovirtmesh=1; %flat set to 0 or 1 that turns remeshing of virtual nodes off or on
% % % 
% % % %Simulation time
% % % % dt0=1E2;
% % % % dt0=1e6*2048*100;
% % % % 
% % % % intSimTime = 0;
% % % % simTime = 0;
% % % % %dtplot=2E-9; %2ns
% % % % % dtplot=5E4;
% % % % % doplot=1; % frame recording: 1 == on, 0 == off
% % % % totalSimTime = (2/amag)/(100*1E3*dx*(1E-4/160E9));
% % % 
% % % curstep = 0;
% % % 
% % % % a=lmin/sqrt(3)*0.5;
% a=5;
% Ec = MU/(4*pi)*log(a/0.1); 
% rann = 4*a; 
% rntol = 2*rann; % need to do convergence studies on all these parameters
% rmax = 2*lmin;
% % % % 
% % % % %Plotting
% % % plotFreq=20; 
% % % % savefreq=20;

simName = date;
simName = strcat(simName, '_dense_tensile_ni_100'); 