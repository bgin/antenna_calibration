 
function [ant,op]=AsapRead(ant_in,op_in,nFeed);

% [Ant,Op]=AsapRead(AIF,AOF) reads data from ASAP input and
% output file (filenames given in the strings AIF and AOF).
% Ant and Op are structures with the fields
%   Ant. Geom, Desc, Wire, Insu
%   Op. Freq, Feed, Load, Exte, Inte, Curr
% as exlained in WriteAsap. The fields are filled when the
% corresponding data are found in the files. Op.Curr is read
% from AOF, all other data from AIF.
%
% [Ant,Op]=AsapRead(AIF) reads just the given ASAP input file,
% storing the data in the corresponding structure.
%
% Curr=AsapRead([],AOF) reads only the currents from the given 
% ASAP output file. 
%
% Revision 01.08 by Thomas Oswald: AIF AOF removed
%   functionality of concept call implemented
%
% These are the ASAP input cards recognized by AsapRead:

CardSet={'WIRE','INSU','GEOM','GXYZ','DESC','DNOD',...
  'FREQ','FEED','GENE','LOAD','IMPE','EXTE','INTE','STOP',...
  'OUTPUT'};

deg=pi/180;

ant=ant_in;
op=op_in;
AIF='asapin.dat';
AOF='asapout.dat';

%-----------------------
% read ASAP input file:
%-----------------------
  
fid=fopen(AIF,'rt');
if fid<0,
  error(['Could not open file ',AIF]);
end

LineNum=0; 

while ~feof(fid)  % MAIN LOOP
  
    [Line,LineNum]=AsapFgetl(fid,LineNum);  
    Card='';
    for k=CardSet,
        p=findstr(Line,k{1});
    
        if ~isempty(p) 
            Card=k{1};
            Line=Line(p(1)+length(Card):end);
            break 
        end
    end
  
    switch Card,
    case 'WIRE',
        [d,du]=Sscann(Line,1);
        p=[];
        q=[];
    
        for k=1:min(length(d),2),
            if findstr(du{k},'RADI'),
                p=d(k);
            elseif findstr(du{k},'COND'),
                q=d(k);
            end
        end

        if isempty(p),
            AsapFerror(fid,...
                'Invalid WIRE card (no RADIUS defined).',LineNum);
        end

        if isempty(q),
            if length(d)>1,
                AsapFerror(fid,...
                    'Invalid WIRE card encountered.',LineNum);
            else
                q=50;
            end
        elseif q<0, 
            q=inf;
        end
        
        ant.Wire=[p,q*1e6];  % Conductivity in MS/m -> in S/m
  
    case 'INSU',
        [d,du]=Sscann(Line,1);
        p=[];
        q=[];
        r=[];
        
        for k=1:min(length(d),3),
            if findstr(du{k},'RADI'),
                p=d(k);
            elseif findstr(du{k},'COND'),
                q=d(k);
            elseif findstr(du{k},'DIEL'),
                r=d(k);
            end
        end

        if isempty(p)|isempty(q)|isempty(r),
            AsapFerror(fid,'Invalid INSU card encountered.',LineNum);
        end

        ant.Insu=[p,q,r];
  
    case 'GEOM',
        p=[];
        q=[];
        
        while ischar(Line),
            p=findstr(Line,')');
        
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
    
            if ~isempty(p) 
                break
            end
            
            [Line,LineNum]=AsapFgetl(fid,LineNum);  
        end

        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within GEOM card.',LineNum);
        end

        p=length(q);
  
        if mod(p,3) | isempty(q),
            AsapFerror(fid,...
                'Invalid number of coordinates in GEOM card.',LineNum);
        end

        ant.Geom=reshape(q,3,p/3)';

    case 'GXYZ',
        q=[];
        p=[];
  
        while ~feof(fid) & isempty(p),
            [Line,LineNum]=AsapFgetl(fid,LineNum);  
            d=sscanf(Line,'%f');
    
            if mod(length(d),3),
                AsapFerror(fid,...
                    'Invalid number of coordinates in GXYZ card.',LineNum);
            elseif isempty(d),
                p=findstr(Line,'XXXX');
                
                if ~all(isspace(Line)) & isempty(p),
                    AsapFerror(fid,'Invalid line in GXYZ card.',LineNum);
                end
            else
                q=[q;d'];
            end
        end % while
        
        p=findstr(Line,'XXXX');
    
        if isempty(p) | isempty(q),
            AsapFerror(fid,...
                'Unexpected end of data within GXYZ card.',LineNum);
        end

        ant.Geom=q;

    case 'DESC',
        p=[];
        q=[];
    
        while ischar(Line),
            p=findstr(Line,')');
        
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
        
            if ~isempty(p)
                break
            end


            [Line,LineNum]=AsapFgetl(fid,LineNum);
        end % while   
  
        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within DESC card.',LineNum);
        end

        p=length(q);
  
        if mod(p,2) | isempty(q),
            AsapFerror(fid,...
            'Invalid number of coordinates in DESC card.',LineNum);
        end

        ant.Desc=reshape(q,2,p/2)';

    case 'DNOD',
        q=[];
        p=[];
  
        while ~feof(fid) & isempty(p),
            [Line,LineNum]=AsapFgetl(fid,LineNum);  
            d=sscanf(Line,'%f');
    
            if mod(length(d),2),
                AsapFerror(fid,...
                    'Invalid number of coordinates in DNOD card.',LineNum);
            elseif isempty(d),
                p=findstr(Line,'XXXX');
            
                if ~all(isspace(Line)) & isempty(p),
                    AsapFerror(fid,'Invalid line in DNOD card.',LineNum);
                end
            else
                q=[q;d'];
            end
        end % while
        
        p=findstr(Line,'XXXX');
    
        if isempty(p) | isempty(q),
            AsapFerror(fid,...
                'Unexpected end of data within DNOD card.',LineNum);
        end

        ant.Desc=q;

    case 'FREQ',
        q=Sscann(Line,1);
  
        if isempty(q),
            AsapFerror(fid,'Invalid FREQ card encountered.',LineNum);
        end

        op.Freq=1e6*q(1);  % Frequency in MHz -> in Hz

    case 'FEED',
        p=[];
        q=[];
  
        while ischar(Line),
            p=findstr(Line,')');
        
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
    
            if ~isempty(p)
                break
            end

            [Line,LineNum]=AsapFgetl(fid,LineNum);
        end % while
        
        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within FEED card.',LineNum);
        end

        p=length(q);
    
        if ((p~=1) & mod(p,3)) | isempty(q),
            AsapFerror(fid,'Invalid FEED card encountered.',LineNum);
        end

        if p==1,
            op.Feed=[q,1];
        else
            q=reshape(q,3,p/3)';
            op.Feed=[q(:,1),q(:,2).*exp(i*q(:,3)*deg)];
        end
  
    case 'GENE',
        p=[];
        q=[];
  
        while ischar(Line),
            p=findstr(Line,')');
    
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
    
            if ~isempty(p)
                break
            end
            
            [Line,LineNum]=AsapFgetl(fid,LineNum);  
        end % while
        
        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within GENE card.',LineNum);
        end

        p=length(q);
  
        if mod(p,3) | isempty(q),
            AsapFerror(fid,'Invalid GENE card encountered.',LineNum);
        end

        q=reshape(q,3,p/3)';
        op.Feed=[i*q(:,1),q(:,2).*exp(i*q(:,3)*deg)];
  
    case 'LOAD',
        p=[];
        q=[];
  
        while ischar(Line),
            p=findstr(Line,')');
            
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
        
            if ~isempty(p)
                break
            end

            [Line,LineNum]=AsapFgetl(fid,LineNum);
  
        end % while   
  
        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within LOAD card.',LineNum);
        end

        p=length(q);
  
        if mod(p,3) | isempty(q),
            AsapFerror(fid,'Invalid LOAD card encountered.',LineNum);
        end

        q=reshape(q,3,p/3)';
        op.Load=[q(:,1),q(:,2).*exp(i*q(:,3)*deg)];
  
    case 'IMPE',
        p=[];
        q=[];
  
        while ischar(Line),
            p=findstr(Line,')');
    
            if ~isempty(p),
                Line=Line(1:p-1);
            end

            q=[q,Sscann(Line,1)];
            
            if ~isempty(p)
                break
            end

            [Line,LineNum]=AsapFgetl(fid,LineNum);
        end % while   
  
        if isempty(p),
            AsapFerror(fid,...
                'Unexpected end of file within IMPE card.',LineNum);
        end

        p=length(q);
  
        if mod(p,3) | isempty(q),
            AsapFerror(fid,'Invalid IMPE card encountered.',LineNum);
        end

        q=reshape(q,3,p/3)';
        op.Load=[i*q(:,1),q(:,2).*exp(i*q(:,3)*deg)];
  
    case 'EXTE',
        [d,du]=Sscann(Line,1);
        p=[];
        q=[];
  
        for k=1:min(length(d),2),
    
            if findstr(du{k},'COND'),
                p=d(k);
            elseif findstr(du{k},'DIEL'),
                q=d(k);
            end
        end

        if isempty(p)|isempty(q),
            AsapFerror(fid,'Invalid EXTE card encountered.',LineNum);
        end
        
        op.Exte=[p,q];  
    case 'INTE',
        q=Sscann(Line,1);
  
        if isempty(q),
            AsapFerror(fid,'Invalid INTE card encountered.',LineNum);
        end

        op.Inte=q(1);
  
    case 'STOP',
        break
  
    otherwise
        if ~all(isspace(Line)) & isempty(Card),
            fprintf(1,'Warning: AsapRead cannot treat input line %d: %s\n',...
            LineNum,Line);
        end
 
    end % of switch

end % of MAIN LOOP

p=fclose(fid);
if p<0,
  error(['Could not close file ',AIF]);
end


%------------------------
% read ASAP output file:
%------------------------


fid=fopen(AOF,'rt');
if fid<0,
  error(['Could not open file ',AOF]);
end

LineNum=0; 
p='ANTENNA BRANCH CURRENTS'; 
d=[];

while ~feof(fid),
  [Line,LineNum]=AsapFgetl(fid,LineNum);  
  if length(Line)>=length(p),
    if ~isempty(findstr(upper(Line),p)),
      break
    end
  end
end

while ~feof(fid),
  [Line,LineNum]=AsapFgetl(fid,LineNum);  
  p=findstr('**',Line);
  Line([p,p+1])='1';  
  q=sscanf(Line,'%f');
  
  if length(q)==13, 
    d(end+1,:)=[q(3)+i*q(4),q(9)+i*q(10)];
  elseif ~isempty(q), 
    break 
  end
end

if isempty(d),
  AsapFerror(fid,'No current data found.',LineNum);
end      

if isempty(AIF),
  ant=d; 
else
  op.Curr(nFeed,:,:)=d; 
end

p=fclose(fid);
if p<0,
  error(['Could not close file ',AOF]);
end


%-------------------------------------------------------------------------

function AsapFerror(fid,Err,L)

% Displays error message Err after closing the file associated 
% with fid. In addition the line number L is output.
% The function is used by AsapRead.

Name=fopen(fid);

fclose(fid);

if nargin>2,
  fprintf(1,'\nASAP format error in line %d of ''%s''\n',L,Name);
end

error(Err);

%-------------------------------------------------------------------------

function [L,N1]=AsapFgetl(fid,N)

% Read line from file associated with identifier fid,
% comment lines are returned empty, letters are modified to
% uppercase. The line number N is increased by 1. If end
% of file is reached, L=-1 is returned.
% This function is used by AsapRead.

if nargin>1,
  N1=N+1;
else
  N1=1;
end

L=deblank(fgetl(fid));

if ~ischar(L),
  N1=N1-1;
  return
end

L=[upper(L),' '];

if L(1)=='C' & isspace(L(2)),
  L='';
end


