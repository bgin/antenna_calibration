
function ConceptWrite(CIF,ant,Op,NB,mode,Nfeed,titl)

% function ConceptWrite(CIF,ant,Op,NB,mode,Nfeed,titl) creates a concept input file 
% by translating given data into one of the concept input files, 
% defined by mode:
%
%   mode=0...just the wire file is generated
%   mode=1...just the surface file is generated
%   mode=2...concept.in is generated...just wires
%   mode=3...concept.in is generated... wires and surfaces
%
%   CIF...the concept input filename 
% 
%   ant...a structure which defines the antenna system.
%
%   Op...defines how the antennas are operated.
%   
%   NB...the number of base functions per wire segment.
%
%   mode...the mode
%
%   Nfeed...The number of antennas (feed points)
%
%   titl...title of the model
%   
%   ant has the following member variables:  
%
%   Geom: array [number of nodes x 3] of double
%
%       This array holds the cartesian coordinates of the nodes.
% 
%   Desc: array [number of segments x 2] of double
% 
%       This array holds the numbers of the nodes of each segment 
%       between which the segment is spanned.
% 
%   Desc2d: array [number of patches] of cell
% 
%       This array holds the numbers of the nodes of each patch 
%       between which the patch is spanned.
% 
%   Obj: array [number of objects] of struct object
% 
%       This array hold the objects comprising the model. Each 
%       objects holds information about the geometry of the part 
%       of the model describing it and how to use it in the 
%       calculation. Every part of the model must be 
%       member of at least one object.
% 
%   Init: integer
% 
%       The number held by this member variable counts the number of 
%       object creating function calls. Its important use is to see 
%       whether the object has been initialized.
% 
%   Antennae: array [number of antennas] of struct
% 
%       This array holds an antenna structure for each antenna of the 
%       spacecraft model. 
% 
%   Config: struct
% 
%       A structure which holds information about the spacecraft model, 
%       i.e. size and geometry issues. This structure is spacecraft 
%       dependent and has therefore no fixed structure.
% 
%   Feed: array [number of feeds] of integer
% 
%       This array holds the node numbers of each point feed of the model. 
%       This variable is mainly used in combination with the ASAP software.
% 
%   SegFeeds: array [number of feeds] of integer
% 
%       Concept uses feeds along given segments. This array holds the 
%       segment numbers of the segments where the feeds are located.
% 
%   Wire: array [2] of double
% 
%       The two numbers of this vector hold the radius of the wires, if a 
%       common radius for alliteC wires is used, and the conductivity of the 
%       surface of the model, when a single conductivity is used for the 
%       whole model.
%
%   Op has the following member variables:
%
%   Feed:
% 
%       This member variable has the same function and content as the 
%       member with the same identifier in the ant structure.
% 
%   SegFeeds:
% 
%       This member variable has the same function and content as the 
%       member with the same identifier in the ant structure.
% 
%   Exte: array [2] of double
% 
%       This array holds information about the external medium 
%       surrounding the spacecraft. It is used by the ASAP software.
% 
%   Inte: integer
% 
%       Inte holds the number of iterations of the numerical integration 
%       performed in the ASAP software. Setting it to zero results in an 
%       analytical integration.
% 
%   EpsilonR: double
% 
%       This member holds the value of the relative permittivity of the 
%       surrounding medium to be used with Concept calculations. It can 
%       be used for a simple model to include the effect of the 
%       surrounding space plasma into the calculations.
% 
%   Freq: double
% 
%       This variable holds the frequency used for the calculation.
% 
%   Curr: array [number of antennas x number of segments x 2] of double
% 
%       This array holds the base coefficients at the end points of each 
%       segment.
% 
%   ConceptCurr: array [number of antennas x number of segments x 2] of
%   double
% 
%       This array holds the base coefficients at the three base-points of 
%       each segment.
% 
%   Excit: array [number of antennas] of double
% 
%       This array holds the excitation voltage of the feed of each 
%       antenna.

deg=pi/180;

if nargin<5,
  mode=0;
  Nfeed=1;
end

% open/create concept input file:

fid=fopen(CIF,'wt');
if fid<0,
  error(['Could not open file ',CIF]);
end

% Wire file:

if(mode==0)
    Nsegs=length(ant.Desc);
    fprintf(fid,'%i\n',Nsegs);
    
    for L=1:Nsegs
        fprintf(fid,'%12.6e %12.6e %12.6e %12.6e %12.6e %12.6e \n',ant.Geom(ant.Desc(L,1),:),ant.Geom(ant.Desc(L,2),:));
    end
    
    fprintf(fid,'%i\n',NB);
end %if

% Surface file:

if(mode==1)
    Nnodes=length(ant.Geom);
    Npats=length(ant.Desc2d);
    fprintf(fid,'%i  %i\n',Nnodes,Npats);
    
    for L=1:Nnodes
        fprintf(fid,'%12.6e %12.6e %12.6e  \n',ant.Geom(L,:));
    end
    
    for L=1:Npats
        switch length(ant.Desc2d{L})
            case 3
                fprintf(fid,'%i %i %i 0 \n',ant.Desc2d{L});
            case 4
                fprintf(fid,'%i %i %i %i \n',ant.Desc2d{L});
            otherwise
                error('ERROR...Concept accepts only patches with 3 or 4 nodes !');
        end % switch
        
    end
    
    
end %if

% write concept.in

if(mode==2)
   writeConceptIn(CIF,ant,Op,NB,mode,Nfeed,titl, fid,false);
end %if

if(mode==3)
    
    % generate surf.1
    
    fid_P=fopen('surf.1','wt');
    if fid<0,
        error('Could not open file surf.1');
    end
    
    
    Nnodes=length(ant.Geom);
    Npats=length(ant.Desc2d);
    fprintf(fid_P,'%i  %i\n',Nnodes,Npats);
    
    for L=1:Nnodes
        fprintf(fid_P,'%12.6e %12.6e %12.6e  \n',ant.Geom(L,:));
    end
    
    for L=1:Npats
        switch length(ant.Desc2d{L})
            case 3
                fprintf(fid_P,'%i %i %i 0 \n',ant.Desc2d{L});
            case 4
                fprintf(fid_P,'%i %i %i %i \n',ant.Desc2d{L});
            otherwise
                error('ERROR...Concept accepts only patches with 3 or 4 nodes !');
        end % switch
        
    end
    
    s=fclose(fid_P);
    if s<0,
        error(['Could not close file surf.1']);
    end
    
    writeConceptIn(CIF,ant,Op,NB,mode,Nfeed,titl, fid,true);
    
end %if

% close completed input file:
  
s=fclose(fid);
if s<0,
  error(['Could not close file ',CIF]);
end

end

% ---------------------------------------------------------------------------

function writeConceptIn(CIF,ant,Op,NB,mode,Nfeed,titl, fid,pats)
     % input information
    
    
    f=Op.Freq;
    epsr= Op.Exte(2);
    
    
    % name
    
    fprintf(fid,'1.1  characterization of the structure\n');
    fprintf(fid,' %s \n',titl);
    
    % symmetry
    % since there is no symmetry expected on spacecraft, I will set this
    % parameter automaticcally to 0, thereby decreasing the number of
    % required parameters.
    
    fprintf(fid,'2.1   symmetry with respect to the xz plane, yz plane or both\n');
    fprintf(fid,'%6d\n',0);
    
    % number of wires, ground=0, segments per wavelength=8, coating =0
    
    Nsegs=length(ant.Desc);
    fprintf(fid,'2.2   number of wires, id. ground, segments per wavelength, coating\n');
    if (epsr~=1)&(epsr~=0)
        fprintf(fid,'%5i %5i %5i %5i\n',Nsegs, 7,8,0);
    else
        fprintf(fid,'%5i %5i %5i %5i\n',Nsegs, 0,8,0);
    end
    
    % wires  

    for L=1:Nsegs
        fprintf(fid,'2.30  wire %i   : coordinates\n', L);
        
        fprintf(fid,'%10.5f %10.5f %10.5f %10.5f %10.5f %10.5f \n',...
            ant.Geom(ant.Desc(L,1),:),ant.Geom(ant.Desc(L,2),:));
        
        fprintf(fid,'2.31  wire %i   : radius, no. of basis functions, RB, EP, MY\n', L); % anscheinend braucht man nur die ersten 2
        
        fprintf(fid,'%10.6f    %i\n',...
            ant.WireRadii(L,1)*1000,3); % radius in mm 
    end %for all wires
    
    % plasma
    
    if (epsr~=1)&&(epsr~=0)
            fprintf(fid,'2.5   tan_delta, rel. permittivity\n'); 
            fprintf(fid,' 0.0000     %11.4f\n', Op.Exte(2)); 
    end % plasma
    
    % check grid
    
    fprintf(fid,'2.6   check wire grid\n');
    fprintf(fid,'%6i\n',1);

    % print out currents...always yes
    
    fprintf(fid,'3.1  print of currents\n');
    fprintf(fid,'%6i\n',1);
    
    % Excitation...at the moment always a feed with one volt
    
    fprintf(fid,'3.2  excitation\n');
    fprintf(fid,'%6i\n',1);
   

    % position of feed (in terms of the wire number) ant the internal
    % resistance, which is 0 for open feeds
    
    fprintf(fid,'3.3  generator position, internal resistance (excitation=1)\n');
    fprintf(fid,'m%-3d    %11.4E\n',ant.SegFeeds(Nfeed),0);
    
    % frequency representation. for us are only 2 possibilities relevant at
    % the moment:
    %
    %   1...single frequency
    %   2...frequency loop
    
    if(length(f)==1)
       fprintf(fid,'4.1  representation of frequency(ies) (1-6)\n'); 
       fprintf(fid,'%6i\n',1);
       
       fprintf(fid,'4.2  basic frequency\n'); 
       fprintf(fid,'%8f\n',f/1e6);
    else
       fprintf(fid,'4.1  representation of frequency(ies) (1-6)\n'); 
       fprintf(fid,'%6i\n',2);
       
       fprintf(fid,'4.3  basic frequency, frequency step width, number of frequencies\n'); 
       fprintf(fid,'%8f      %8f        %i\n',f(1)/1e6,(f(length(f))-f(1))/((length(f)-1)*1e6), length(f)); 
    end

    % skin effect...finite conductivity ? yes/no/maybe...I thing only yes
    % is an option for us
    
    if (epsr==1)|(epsr==0)
        fprintf(fid,'5.1  skin effect (1/0)\n'); 
        fprintf(fid,'%6d\n',1);
        
        fprintf(fid,'5.2  number: conductivity value(s), observation point(s) E tang\n'); 
        fprintf(fid,'%6d     %i\n',1,0);
    
        fprintf(fid,'5.3  conductivity value(s) in S/m (max. 3 per line)\n'); 
        fprintf(fid,'%E\n',ant.wire(2));
 
        fprintf(fid,'5.4  conductivity domain(s)\n'); 
        fprintf(fid,'%6d\n',Nsegs);
    else
        fprintf(fid,'5.1  skin effect (1/0)\n'); 
        fprintf(fid,'%6d\n',0);     % epsilon+scin effect packts concept net
    end % no skin effect
        

    % jetzt kommt nur blabla
    
    fprintf(fid,'6.1  number of load impedances\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'7.1  current distribution on wires\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'7.3  number of currents at discrete points\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'9.0  rcs (0/1)\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'9.1  number of field points\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'10.3  total number of "cable wires"\n'); 
    fprintf(fid,'%6i\n',0);
    fprintf(fid,'11.1  surface currents (0/1/2/3/4)\n'); 
    
    if pats==true
     fprintf(fid,'%6i\n',1);    % value for patches
    else
     fprintf(fid,'%6i\n',0);    % value for wires
    end
    
    fprintf(fid,'11.10   check surface grid (0/1)\n');
    fprintf(fid,'%6i\n',1);
    fprintf(fid,'11.11  physical optics (0/1)\n');
    fprintf(fid,'%6d\n',0);
    
    % method to solve the system of equation...12 is the normal LU
    % decomposition with row pivoting...works always
    
    fprintf(fid,'12.1  direct: 11,12,13, special direct solv. 21,22, iter. solver: 31,32,33\n'); 
    fprintf(fid,'%6d\n',12);
    
end
