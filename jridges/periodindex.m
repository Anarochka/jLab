function[index]=periodindex(varargin)
%PERIODINDEX  Returns time index in increments of instantaneous period.
%
%   INDEX=PERIODINDEX(DT,OMEGA,N) returns a time index INDEX that skips 
%   every N times the instantaneous period 2*pi/OMEGA.
%
%   OMEGA is a column vector of instantaneous frequency in radians per unit 
%   time as computed by INSTMOM. DT is the sample time, a scalar.  The
%   units of 2*pi/OMEGA should be the same as the units of DT.
%
%   Then PERIODINDEX constructs an index into a vector of the same length
%   as OMEGA that skips every N times the instantaneous period 2*pi/OMEGA.
%   Thus N=1 returns an index with one sample per period, etc.
%
%   The first and last N periods are omitted from the index.  Specifically,
%   the first value of INDEX is N times first value of 2*pi/OMEGA, and 
%   the last value of INDEX is not larger than the length of OMEGA minus
%   N times the last value of 2*pi/OMEGA.
%
%   If NaNs are found within the OMEGA, this is interpreted as being
%   separate ridges output by RIDGEWALK.  Then INDEX will be a cell array 
%   with the period index for each ridge of OMEGA in a separate cell.
%
%   INDEX=PERIODINDEX(OMEGA,N) also works, in which case DT is taken to be
%   as unity.  Thus OMEGA must have units of radians per sample interval.
%
%   PERIODINDEX is useful with ELLIPSEPLOT for plotting ellipses a
%   specified number of periods apart.
%   ___________________________________________________________________
%
%   Cell array input / output
%
%   PERIODINDEX returns cell array output given cell array input.  
%
%   That is, if OMEGA is a cell arrays of length K, containing K different 
%   numerical arrays, then INDEX will also be cell arrays of length K.  
%
%   In this case DT may be either a scalar, or an array of length K.
%
%   If the cells of OMEGA are found to contain NaNs, these are interpreted
%   as separating individual ridges, and INDEX will in this case be a cell
%   array of length OMEGA with each element containing one cell per ridge.
%   ___________________________________________________________________
%
%   See also ELLIPSEPLOT.
%
%   Usage: index=periodindex(dt,omega,N);
%   __________________________________________________________________
%   This is part of JLAB --- type 'help jlab' for more information
%   (C) 2011--2016 J.M. Lilly --- type 'help jlab_license' for details
 


if nargin==3
    dt=varargin{1};
    varargin=varargin(2:3);
else
    dt=1;
end

om=varargin{1};
N=varargin{2};

if iscell(om)
    if length(dt)==1
        dt=dt+zeros(size(om));
    end
    for i=1:length(om)
        if ~any(isnan(om{i}))
           index{i,1}=periodindex_loop(dt(i),abs(om{i}),N);
        else
           omi=col2cell(om{i});
           for j=1:length(omi)
              index{i,1}{j}=periodindex_loop(dt(i),abs(omi{j}),N);
           end
        end
    end
else
    if ~any(isnan(om))
        index=periodindex_loop(dt,abs(om),N);
    else
        om=col2cell(om);
        for j=1:length(om)
            index{j}=periodindex_loop(dt,abs(om{j}),N);
        end
    end
end


function[index]=periodindex_loop(dt,om,N)
index=[];

om(om==inf)=nan;

if ~isempty(om)
    if anyany(~isnan(om))
        skip=ceil(N*frac(2*pi,om.*dt));
        [L,ia,ib]=blocklen(~isnan(skip));
        
        %alternating ones and zeros
        % ia,ib,skip(ia),skip(ib)
        for i=1:length(ia)
            % i
            if ~isnan(skip(ia(i)))
                if ia(i)+skip(ia(i))<= length(skip)
                    first=skip(ia(i)+skip(ia(i)));
                    if ~isnan(first)
                        index(end+1,1)=ia(i)+skip(ia(i));
                        while index(end)+skip(index(end))<ib(i)
                            %xxx=index(end)
                            %yyy=skip(index(end))
                            %zzz=ib(i)
                            %  skip(index(end))
                            
                            index(end+1,1)=index(end)+skip(index(end));
                        end
                        if index(end)>ib(i)-skip(ib(i))
                            index=index(1:end-1);
                        end
                    end
                end
            end
        end
    end
end


%reporttest('PERIODINDEX',aresame())
