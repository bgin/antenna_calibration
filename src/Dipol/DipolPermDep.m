
% DipolePermDep is a routine which plots the relative variation of the 
% effective length vector as function of the permittivity

% parameters 

f1=3e5;
f2=1e6;
f3=10e6;

solver=2;
ca=0;
force=1;
forcegain=0;
forcegridcreate=1;

f_pe=1e5;
epsilonr=0.5;
%epsilonr=1-(f_pe/f)^2;

asapexe='asap2d.bin';
nec2bin='nec2++';

switch(solver)
    case 1  % asap
        CurrentFile='ASAPCurrents.mat';
        GainFile='ASAPGain.mat';
        titl='Test dipole/ASAP';
    case 2  % concept  
        CurrentFile='Currents.mat';
        GainFile='Gain.mat';
        titl='Test dipole/CONCEPT';
    case 3  % NEC 2
        CurrentFile='NEC2Currents.mat';
        GainFile='NEC2Gain.mat';
        titl='Test dipole/NEC 2';
end % switch

er=[0,0,01];

% load model
 
ant=CreateDipole(solver);



eps=0.1:0.1:1;
        
Heff1=zeros(length(eps),1);
Heff2=zeros(length(eps),1);
%Heff3=zeros(length(eps),1);

for(n=1:length(eps))
   OP1=DipolCurrent(f1,ant,solver,asapexe, titl,eps(n),nec2bin);
   OP2=DipolCurrent(f2,ant,solver,asapexe, titl,eps(n),nec2bin);
 %  OP3=DipolCurrent(f3,ant,solver,asapexe, titl,eps(n),nec2bin);
    
    % ohne capacit?ten
    
    if ca==0
        TM1=AntTransferx(ant,OP1,er,solver,0,0);
        TM2=AntTransferx(ant,OP2,er,solver,0,0);
  %      TM3=AntTransferx(ant,OP3,er,solver,0,0);
        
        titstr=strcat(titl,'...without capacitances\n\n');
    else
        caps=1/70e-12;
        impedances=caps./(i*OP.Freq*2*pi);
        switch solver
            case 1
                TM=AntTransferx(ant,OP,er,solver,5,15/1000,impedances); 
            case 2
                TM=AntTransferx(ant,OP,er,solver,0,25.4/1000,impedances);
        end % switch
        titstr=strcat(titl,'...with capacitances\n\n');
    end
    
    TPR1=ThetaPhiR(TM1);
    TPR2=ThetaPhiR(TM2);
 %   TPR3=ThetaPhiR(TM3);

    Heff1(n)=TPR1(3);
    Heff2(n)=TPR2(3);
  %  Heff3(n)=TPR3(3);
end % for all eps

figure
plot(eps,real(Heff1),'b');
line(eps,real(Heff2),'color','r');
%line(eps,real(Heff3),'color','g');
title('Real part of the length of the effective length vector');
xlabel('Equivalent permittivity');
ylabel('Heff');
legend('300kHz','1MHz','10MHz');

relHeff1=Heff1/Heff1(end)*100;
relHeff2=Heff2/Heff2(end)*100;
%relHeff3=Heff3/Heff3(end)*100;


figure
plot(eps,real(relHeff1),'b');
line(eps,real(relHeff2),'color','r');
%line(eps,real(relHeff3),'color','g');
title('Equivalent Real part of the length of the effective length vector');
xlabel('Equivalent permittivity');
ylabel('Heff/Heff in Vacuum [%]');

legend('300kHz','1MHz','10MHz');
