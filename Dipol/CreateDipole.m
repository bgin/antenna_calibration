function ant=CreateDipole(solver)

% CreateDipole
% generate single 6m dipole for testing
% ===========================================================


if(nargin<1)
    solver=2;
end

ant=GridInit;  

if(solver==1)% asap
    ant=struct(...     
        'Feed',101,...      
        'SegFeeds',100,...         
        'Wire',[5e-3,50e6]);
    
        ant.Geom(:,3)=[-3:6/200:3];
        ant.Desc(:,1)=1:200;
        ant.Desc(:,2)=2:201;
else % concept
        ant=struct(...
        'Feed',50,...      
        'SegFeeds',49,...        
        'Wire',[5e-3,50e6]);
    
        ant.Geom(:,3)=[-3:6/99:3];
        ant.Desc(:,1)=1:99;
        ant.Desc(:,2)=2:100;  
        ant.WireRadii=zeros(99,1);
        ant.WireRadii(:,1)=5e-3;
        
end % concept

ant=SetWiretype(ant);


h=[];

hold on;
PlotGrid(ant,'all',[],'all','all');
axis equal;
set(gcf,'renderer','opengl');

title('Dipole');
xlabel('X-Axis');
ylabel('Y-Axis');
zlabel('Z-Axis');

