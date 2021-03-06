function [A,E,E_r,E_t,B]=mcFullField(ant,cs, nTheta, nPhi,dist,output,...
    freqrelsqu, ioneffect)

%   function [A,E_r,E_t,B]=mcFarField(ant,cs, NN,dist,output)
%
%   This function computes the components of the fields either as 
%   function of theta and phi at distance dist from the phase center if 
%   the parameter output is set to 1, or up to a distance of dist if 
%   output=2. 
%
%   ant...antenna structure
%   cs...current structure
%   nTheta, nPhi...number of points in theta and phi direction 
%   dist...distance from the phase center
%   output...method of output:  1...The fields are calculated at a distance
%                                   dist from the phase center
%                               2...A Grid is constructed from r=0 to
%                                   r=dist with NN points in theta and phi
%                                   direction. The E and B vectors are
%                                   displayed.
%                               3...Shows the E and B Field vectors
%                                   projected on the horizontal and the
%                                   vertical plane, each in the center
%   
%   frequrelsequ...omega_pe^2/omega^2
%   ioneffect...consider the effect of ions ?   0...no
%                                               1...jep
%
%   For the radio approximation set ionrelsequ to 0 to ignore the effect of
%   the ions. For the vacuum case, set also frequrelsequ to zero to ignore
%   also the effects of the electrons...but why do You use this function
%   then ?


% constants

if nargin<8
    ioneffect=0;   % radio approximation
end % if

if nargin<7
   freqrelsqu=0;   % radio approximation
end % if

if nargin<6
   output=0;   
end % if



mu=4*pi*1e-7;    % henry/meter...free space
epsilon0=8.8542e-12;   % parad/meter...free space
Z0=376.7;  % ohm...impedance of free space


ionrelsequ=ioneffect*freqrelsqu/2000 % omega_pe/omega_pi = 1/sqrt(2000)
epsilon_r=(1-freqrelsqu-ionrelsequ);
epsilon=epsilon0*epsilon_r;  % epsilon=epsilon0*(1-omega_pe^2/omega^2-omega_pi^2/omega^2)
% parameter



N=ant.nSegs;

wavelength=3e8/cs.f;
k=sqrt(epsilon_r)*2*pi/wavelength;
omega=2*pi*cs.f;
ZP=Z0/sqrt(epsilon_r);

if nargin<5
   dist=wavelength*10;
end % if

if nargin<4
   nPhi=36;
end % if

if nargin<3
   nTheta=18;
end % if

if(nargin<2)
    error('Not enough parameters');
end

switch(output)
    case(1)
        E_r=zeros(NN,NN);
        E_t=zeros(NN,NN);
        
        E_1=zeros(NN,NN);
        E_2=zeros(NN,NN);
        E_3=zeros(NN,NN);
        
        B=zeros(NN,NN);

        fprintf('Working on segment 000');
        theta=linspace(0,pi,NN);
        phi=linspace(0,2*pi,NN);


%   compute lengths and midpoints of segments

        for(n=1:N)
            l(n)=norm((ant.nodes(ant.segs(n,2),:)-ant.nodes(ant.segs(n,1),:)),'fro');
            mid(n,:)=(ant.nodes(ant.segs(n,1),:)+ant.nodes(ant.segs(n,2),:))./2;
        end

%   compute fields

        for(n=1:N)
            fprintf('\b\b\b\b%4i',n);
            for(t=1:NN)
                for(p=1:NN)
                    % compute distance s and the real angle
            
                    point = [0,0,ant.length/2]+dist*[cos(phi(p))*sin(theta(t)),sin(phi(p))*sin(theta(t)),cos(theta(t))]; 
                    s=norm(point-mid(n,:),'fro');
                   % realtheta=atan2(sqrt(point(1)^2+point(2)^2),point(3)-mid(n,3));
%                    sintheta=sqrt(point(1)^2+point(2)^2)/s;
%                     costheta=(point(3)-mid(n,3))/s;
                    
            % compute fields
            
                    commonterm=(-k^2+3*(i*k+1/s)/s)/s;
                    
                    E_1(t,p)=E_1(t,p)+1/(4*pi*i*epsilon*omega)*(exp(-i*k*s)/s^2)*(commonterm*point(1)*(point(3)-mid(n,3)))*l(n)*cs.I(n);
                    E_2(t,p)=E_2(t,p)+1/(4*pi*i*epsilon*omega)*(exp(-i*k*s)/s^2)*(commonterm*point(2)*(point(3)-mid(n,3)))*l(n)*cs.I(n);
                    E_3(t,p)=E_3(t,p)+1/(4*pi*i*epsilon*omega)*(exp(-i*k*s)/s^2)*(commonterm*(point(3)-mid(n,3))^2-(i*k-s*k^2+1/s))*l(n)*cs.I(n);
                    
                 
                   
                end
            end
        end % for all segments

        E=sqrt(E_1.^2+E_2.^2+E_3.^2);
% plot graphs
        Plot2d_1(theta,abs(real(E)),'Electric field as function of colatitude',NN)
        Plot3d_1(theta,phi,real(E),'Electric field',NN);
        
        
        
%         Plot2d_1(theta,abs(real(B)),'Magnetic induction field as function of colatitude',NN)
%         Plot3d_1(theta,phi,real(B),'Magnetic induction field',NN);
%         Plot3d_1(theta,phi,abs(real(B)),'Magnitude of the magnetic induction field',NN);
    case(2)
        E_r=zeros(NN,NN,NN);
        E_t=zeros(NN,NN,NN);
        B=zeros(NN,NN,NN);

        fprintf('Working on segment 000');
        
        theta=linspace(0,pi,NN);
        phi=linspace(0,2*pi,NN);
        r=linspace(1,dist,NN);

%   compute lengths and midpoints of segments

        for(n=1:N)
            l(n)=norm((ant.nodes(ant.segs(n,2),:)-ant.nodes(ant.segs(n,1),:)),'fro');
            mid(n,:)=(ant.nodes(ant.segs(n,1),:)+ant.nodes(ant.segs(n,2),:))./2;
        end

%   compute fields

        for(n=1:N)
            fprintf('\b\b\b\b%4i',n);
            for(t=1:NN)
                for(p=1:NN)
                    for(rr=1:NN)
                    % compute distance s and the real angle
            
                        point = [0,0,ant.length/2]+r(rr)*[sin(phi(p))*sin(theta(t)),cos(phi(p))*sin(theta(t)),cos(theta(t))]; 
                        s=norm(point-mid(n,:),'fro');
                        realtheta=atan2(sqrt(point(1)^2+point(2)^2),point(3)-mid(n,3));
                        costheta=(point(3)-mid(n,3))/s;
            % compute fields
                        E_r(t,p,rr)=E_r(t,p,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*((1/(i*k*s))+(1/(i*k*s)^2))*2*costheta;
                        E_t(t,p,rr)=E_t(t,p,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s))+(1/(i*k*s)^2))*sin(realtheta);
                        B(t,p,rr)=B(t,p,rr)+((mu*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s)))*sin(realtheta);
                    end
                end
            end
        end % for all segments


% plot graph

        fprintf('\nTransforming the coordinates !');
        n=1;
        for(t=1:NN)
            for(p=1:NN)
                for(rr=1:NN)
                    [X(n),Y(n),Z(n)]=sph2cart(phi(p),pi/2-theta(t),r(rr));
                
                    Etx(n)=real(E_t(t,p,rr))*cos(theta(t))*cos(phi(p));
                    Ety(n)=real(E_t(t,p,rr))*cos(theta(t))*sin(phi(p));
                    Etz(n)=-real(E_t(t,p,rr))*sin(theta(t));
                
                    Erx(n)=real(E_r(t,p,rr))*sin(theta(t))*cos(phi(p));
                    Ery(n)=real(E_r(t,p,rr))*sin(theta(t))*sin(phi(p));
                    Erz(n)=real(E_r(t,p,rr))*cos(theta(t));
                
                    Bx(n)=-real(B(t,p,rr))*sin(phi(p));
                    By(n)=real(B(t,p,rr))*cos(phi(p));
                    Bz(n)=0;
                
                    n=n+1;
                end
            end
        end
    
 
        Ex=Etx+Erx;
        Ey=Ety+Ery;
        Ez=Etz+Erz;
    
        fprintf('\nNormalizing vectors !');
    
        for(n=1:length(Ex))
            Ex_n(n)=Ex(n)/norm([Ex(n),Ey(n) ,Ez(n)],'fro');
            Ey_n(n)=Ey(n)/norm([Ex(n),Ey(n) ,Ez(n)],'fro');
            Ez_n(n)=Ez(n)/norm([Ex(n),Ey(n) ,Ez(n)],'fro');
            
            Bx_n(n)=Bx(n)/norm([Bx(n),By(n) ,Bz(n)],'fro');
            By_n(n)=By(n)/norm([Bx(n),By(n) ,Bz(n)],'fro');
            Bz_n(n)=Bz(n)/norm([Bx(n),By(n) ,Bz(n)],'fro');
        end
    
        fprintf('\nPlotting !');
    
        figure;
        quiver3(X,Y,Z,Ex,Ey,Ez);
        title('Electric field');

        figure;
        quiver3(X,Y,Z,Ex_n,Ey_n,Ez_n);
        title('Electric field, normalized');

        figure;
        quiver3(X,Y,Z,Bx,By,Bz);
        title('Magnetic induction field');

        figure;
        quiver3(X,Y,Z,Bx_n,By_n,Bz_n);
        title('Magnetic induction field, normalized');
    case(3)
        E_r_v=zeros(NN,NN); %   vertical plane
        E_r_h=zeros(NN,NN);%   horizontal plane 
        
        E_t_v=zeros(NN,NN);
        E_t_h=zeros(NN,NN);
        
        B_v=zeros(NN,NN);
        B_h=zeros(NN,NN);

        fprintf('Working on segment 000');
        
        theta=linspace(0,pi,NN);
        phi=linspace(0,2*pi,NN);
        r=linspace(1,dist,NN);

%   compute lengths and midpoints of segments

        for(n=1:N)
            l(n)=norm((ant.nodes(ant.segs(n,2),:)-ant.nodes(ant.segs(n,1),:)),'fro');
            mid(n,:)=(ant.nodes(ant.segs(n,1),:)+ant.nodes(ant.segs(n,2),:))./2;
        end

%   compute fields

        for(n=1:N)
            fprintf('\b\b\b\b%4i',n);
            
            % vertical plane
            
            p=1;
            for(t=1:NN)    
                for(rr=1:NN)
                    % compute distance s and the real angle
            
                    point = [0,0,ant.length/2]+r(rr)*[sin(phi(p))*sin(theta(t)),cos(phi(p))*sin(theta(t)),cos(theta(t))]; 
                    s=norm(point-mid(n,:),'fro');
                    realtheta=atan2(sqrt(point(1)^2+point(2)^2),point(3)-mid(n,3));
                    costheta=(point(3)-mid(n,3))/s;
            % compute fields
                    E_r_v(t,rr)=E_r_v(t,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*((1/(i*k*s))+(1/(i*k*s)^2))*2*costheta;
                    E_t_v(t,rr)=E_t_v(t,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s))+(1/(i*k*s)^2))*sin(realtheta);
                    B_v(t,rr)=B_v(t,rr)+((mu*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s)))*sin(realtheta);
                end
            end
            
            % horizontal plane
            
            th=pi/2;
            for(p=1:NN)    
                for(rr=1:NN)
                    % compute distance s and the real angle
            
                    point = [0,0,ant.length/2]+r(rr)*[sin(phi(p))*sin(th),cos(phi(p))*sin(th),cos(th)]; 
                    s=norm(point-mid(n,:),'fro');
                    realtheta=atan2(sqrt(point(1)^2+point(2)^2),point(3)-mid(n,3));
                    costheta=(point(3)-mid(n,3))/s;
            % compute fields
                    E_r_h(p,rr)=E_r_h(p,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*((1/(i*k*s))+(1/(i*k*s)^2))*2*costheta;
                    E_t_h(p,rr)=E_t_h(p,rr)+((ZP*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s))+(1/(i*k*s)^2))*sin(realtheta);
                    B_h(p,rr)=B_h(p,rr)+((mu*k*cs.I(n)*l(n)*i)/(4*pi*s))*exp(-i*k*s)*(1+(1/(i*k*s)))*sin(realtheta);
                end
            end
           
        end % for all segments


% plot graph

    fprintf('\nTransforming the coordinates !');
    
    n=1;
    p=1;
    for(t=1:NN)
        for(rr=1:NN)
                
            [X_v(n),Y_v(n),Z_v(n)]=sph2cart(phi(p),pi/2-theta(t),r(rr));
                
            Etvx(n)=real(E_t_v(t,rr))*cos(theta(t))*cos(phi(p));
            Etvy(n)=real(E_t_v(t,rr))*cos(theta(t))*sin(phi(p));
            Etvz(n)=-real(E_t_v(t,rr))*sin(theta(t));
                
            Ervx(n)=real(E_r_v(t,rr))*sin(theta(t))*cos(phi(p));
            Ervy(n)=real(E_r_v(t,rr))*sin(theta(t))*sin(phi(p));
            Ervz(n)=real(E_r_v(t,rr))*cos(theta(t));

            Bvx(n)=-real(B_v(t,rr))*sin(phi(p));
            Bvy(n)=real(B_v(t,rr))*cos(phi(p));
            Bvz(n)=0;

            n=n+1;
        end
    end
    
    n=1;
    for(p=1:NN)
        for(rr=1:NN)
                
            [X_h(n),Y_h(n),Z_h(n)]=sph2cart(phi(p),0,r(rr));
                
            Ethx(n)=real(E_t_h(t,rr))*cos(th)*cos(phi(p));
            Ethy(n)=real(E_t_h(t,rr))*cos(th)*sin(phi(p));
            Ethz(n)=-real(E_t_h(t,rr))*sin(th);
                
            Erhx(n)=real(E_r_h(t,rr))*sin(th)*cos(phi(p));
            Erhy(n)=real(E_r_h(t,rr))*sin(th)*sin(phi(p));
            Erhz(n)=real(E_r_h(t,rr))*cos(th);

            Bhx(n)=-real(B_h(t,rr))*sin(phi(p));
            Bhy(n)=real(B_h(t,rr))*cos(phi(p));
            Bhz(n)=0;

            n=n+1;
        end
    end
 
    Evx=Etvx+Ervx;
    Evy=Etvy+Ervy;
    Evz=Etvz+Ervz;
    
    Ehx=Ethx+Erhx;
    Ehy=Ethy+Erhy;
    Ehz=Ethz+Erhz;
    
    fprintf('\nNormalizing vectors !');
    
    for(n=1:length(Evx))
        Evx_n(n)=Evx(n)/norm([Evx(n),Evy(n) ,Evz(n)],'fro');
        Evy_n(n)=Evy(n)/norm([Evx(n),Evy(n) ,Evz(n)],'fro');
        Evz_n(n)=Evz(n)/norm([Evx(n),Evy(n) ,Evz(n)],'fro');

        Bvx_n(n)=Bvx(n)/norm([Bvx(n),Bvy(n) ,Bvz(n)],'fro');
        Bvy_n(n)=Bvy(n)/norm([Bvx(n),Bvy(n) ,Bvz(n)],'fro');
        Bvz_n(n)=Bvz(n)/norm([Bvx(n),Bvy(n) ,Bvz(n)],'fro');
    end
    
    for(n=1:length(Ehx))
        Ehx_n(n)=Ehx(n)/norm([Ehx(n),Ehy(n) ,Ehz(n)],'fro');
        Ehy_n(n)=Ehy(n)/norm([Ehx(n),Ehy(n) ,Ehz(n)],'fro');
        Ehz_n(n)=Ehz(n)/norm([Ehx(n),Ehy(n) ,Ehz(n)],'fro');

        Bhx_n(n)=Bhx(n)/norm([Bhx(n),Bhy(n) ,Bhz(n)],'fro');
        Bhy_n(n)=Bhy(n)/norm([Bhx(n),Bhy(n) ,Bhz(n)],'fro');
        Bhz_n(n)=Bhz(n)/norm([Bhx(n),Bhy(n) ,Bhz(n)],'fro');
    end
    
    fprintf('\nPlotting !');
    
    figure;
    quiver(X_h,Y_h,Ehx,Ehy);
    title('Electric field in the horizontal plane');
    
    figure;
    quiver(X_h,Y_h,Ehx_n,Ehy_n);
    title('Electric field in the horizontal plane, normalized');
    
    figure;
    quiver(X_v,Z_v,Evx,Evz);
    title('Electric field in the vertical plane');
    
    figure;
    quiver(X_v,Z_v,Evx_n,Evz_n);
    title('Electric field in the vertical plane, normalized');
    
    figure;
    quiver(X_h,Y_h,Bhx,Bhy);
    title('Magnetic induction field in the horizontal plane');
    
    figure;
    quiver(X_h,Y_h,Bhx_n,Bhy_n);
    title('Magnetic induction field in the horizontal plane, normalized');
    
    figure;
    quiver(X_v,Z_v,Bvx,Bvz);
    title('Magnetic induction field in the vertical plane');
    
    figure;
    quiver(X_v,Z_v,Bvx_n,Bvz_n);
    title('Magnetic induction field in the vertical plane, normalized');
        
end % switch

%------------------------------------------------------------------------

function Plot3d_1(theta,phi,data,titl,NN)
    figure
    for t=1:NN
        for p=1:NN
            x(t,p)=data(t,p)*cos(phi(p))*sin(theta(t));
            y(t,p)=data(t,p)*sin(phi(p))*sin(theta(t));
            z(t,p)=data(t,p)*cos(theta(t));
        end
    end

    gh=surf(x,y,z,data);
    hold on
    set(gh,'edgecolor','none','facecolor','interp');
    colorbar
    title(titl);
return

%-----------------------------------------------------------------------

function Plot2d_1(theta,data,titl,NN)
    figure
    polar(theta(1,:),data(:,1)');
    hold on
    polar(-theta(1,:),data(:,1+floor(NN/2))');
    hold off
    title(titl);
return