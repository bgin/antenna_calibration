
function [Z,To,Op,PhysGrid]=CalcAnt(AntGrid,DataRootDir,Solver,Freq,...
  er,Titel,WireOption,FarFieldOption)

% [Z,To,Op,PhysGrid]=CalcAnt(AntGrid,DataRootDir,Solver,Freq,...
%   er,Titel,WireOption,FarFieldOption)
% calculates antenna currents (returned in Op), impedance matrices Z, 
% and transfer maztrices (To) for open ports. The physical antenna grid
% for the given Solver is returned in PhysGrid. The antenna parameters
% (Z,To,Op) are calculated for all given frequencies (in vector Freq).
%
% The transfer matrices are calculated for all directions er.
% er contains unit vectors as rows showing in the respective direction from 
% which the wave comes in (antiparallel to wave vector of incident wave).
% If er=[] is passed, no tranfer matrices are calculated and To=[] returned.
%
% Titel is an optional title or short comment for the antenna system.
%
% WireOption may be {}, {'ForceWires'} or {'OnlyWires'}, for explanation
% see the function PhysGrid.
% 
% FarFieldOption may be 'Matlab' or 'Solver' and defines how the far field
% for the determination of To is calculated (by Matlab toolbox routines or
% by the programs implemented in the respective solver).
%
% Default values: er=[]; Titel=''; WireOption={}; FarFieldOption='Matlab'

global Atta_ToFileName Atta_CalcAnt_Recalc

if ~exist('er','var')||isempty(er),
  er=[];
end

if ~exist('Titel','var')||isempty(Titel),
  Titel='';
end

if ~exist('WireOption','var')||isempty(WireOption),
  WireOption={};
end

if ~exist('FarFieldOption','var')||isempty(FarFieldOption),
  FarFieldOption='Matlab';
end

if isfield(AntGrid,'Solver')&&isfield(AntGrid,'Geom_'),
  PhysGrid=AntGrid;
else
  PhysGrid=GetPhysGrid(AntGrid,Solver,WireOption,DataRootDir);
end

Recalc=ismember(upper({'Curr','To'}),upper(Atta_CalcAnt_Recalc));
  
FeedNum='sys';
  
Z=[];
To=[];
Op=struct('Freq',{});

NFreqs=numel(Freq);

for n=1:NFreqs,
  RecalcCurr=0;
  if ~RecalcCurr,
    try
      Op=LoadCurr(DataRootDir,PhysGrid,Freq(n),FeedNum);
    catch
      RecalcCurr=1;
    end
  end
  if RecalcCurr,
    Op=CalcCurr(PhysGrid,Freq(n),FeedNum,Titel,DataRootDir,er);
  end
  
  if isempty(er),
    Z(:,:,n)=CalcZ(Op,FeedNum);
    To=[];
  else
    RecalcTo=Recalc(2);
    
    if ~RecalcTo,
      try
        [To,ex,Z(:,:,n)]=LoadT(DataRootDir,Solver,Freq(n),Atta_ToFileName);
        if ~isequal(ex,er),
          RecalcTo=1;
        end
      catch
        RecalcTo=1;
      end
    end % if ~RecalcTo

    if RecalcTo,
      [To,Z(:,:,n)]=CalcTo(er,PhysGrid,Op,DataRootDir,FarFieldOption);
    end
    
  end % else

end % for

if NFreqs>1,

  if nargout>2,
    Op=LoadCurr(DataRootDir,PhysGrid,Freq(:),FeedNum);
  end
  
  if ~isempty(er)&&(nargout>1),
    To=LoadT(DataRootDir,Solver,Freq(:),Atta_ToFileName);
  end
  
end


    