function findExtremes(rotated, side, trackname, outdir, provenance)
%function findExtremes(rotated, side, trackname, outdir, provenance, selfAblatedRotated, inteAblatedRotated)
%function findExtremes(rotated, side, trackname, outdir, provenance)
% We often want to examine places which are very high or very low on some dimension.
% For each dimension this function finds such places and writes information to a file 
%
% rotated: 2D matrix containing dimensional values for each timepoint
% side: current side of track (l or r)
% trackname: current track name
% outdir: directory where the extremes-listing files will be written

% Paola Gallardo, UTEP, March 2015, modified by Nigel Ward, April 2015

[ntimepoints, ndimensions] = size(rotated);
nseconds = ntimepoints/100;
timestamps = 0.01:0.01:nseconds;     % 0.01 second (10-millisecond) timestamps
%Read only first 50 dimensions (or ndimensions if dimensions < 50)
dimensionsToWrite = min(50, ndimensions) ;

%set up working-copy matrices to find local max and min values in rotated

for dim=1:dimensionsToWrite
    filename = sprintf('dim%.2d.txt', dim);
	  pathname = [outdir filename];   % outdir should already have been created
    if (exist(pathname, 'file' ) == 2)
      fid = fopen(pathname,'at');
    else
      fid = fopen(pathname,'w');
    end

    dimslice = rotated(:,dim);
    maxIndices = findIndicesOfMaxima(dimslice);
    minIndices = findIndicesOfMaxima(-1 * dimslice);

    % !! temporary
    % varient to exclude from consideration all timepoints where this dimension's value is
    %   not large relative to the other dimensions' values 
    %  Since the earlier dimensions tend to have larger values than later ones
    %    we make the threshold lower for later dimensions
    %    Empirically this equation kills 20-90% of the timepoints, which is fine.
          lThresh = 1 / sqrt(dim);
          dimsliceForMin = -1 * dimslice;
          %dimsliceForMin( abs(dimslice) < lThresh * abs(max(rotated,[],2))) = 0;   
          dimsliceForMax = dimslice;
          %dimsliceForMax( abs(dimslice) < lThresh * abs(max(rotated,[],2))) = 0;   

          %fprintf('dimension %2d: number of nonzeros in dimssliceForMin is %d (of %d)\n', ...
	  %	  dim, nnz(dimsliceForMin), length(dimslice));
          %fprintf('dimension %2d: number of nonzeros in dimssliceForMax is %d\n', ...
	  %	  dim, nnz(dimsliceForMax));
          %[val,ix] = max(dimsliceForMax);
          %fprintf(' overall max for dimsliceForMax is %.2f at %d\n', val, ix);
		       
          minIndices = findIndicesOfMaxima(dimsliceForMin);
          %fprintf('for Min got \n');
          %disp(minIndices);

          maxIndices = findIndicesOfMaxima(dimsliceForMax);
          %fprintf('for Max got \n');
          %disp(maxIndices);


    fprintf(fid, '%s\n', provenance);
    fprintf(fid, 'Low\n');
    writeExtrema(fid, minIndices, dim, ...
	   rotated, timestamps, trackname, side);
    fprintf(fid, 'High\n');
    writeExtrema(fid, maxIndices, dim, ...
	   rotated, timestamps, trackname, side);
    fclose(fid);
end  
end


function  writeExtrema(fid, indices, dim, rotated, timestamps, trackname, side)
    numOfExtremesPerTrack = 10;
    for i = 1:numOfExtremesPerTrack;
     index = indices(i);
     actualValue = rotated(index, dim);
     time = timestamps(index);

     % also compute value relative to sum of values of other dimensions at that timepoint
     relativeValAll = actualValue / sum(abs(rotated(index,:)));  
     residue =  sum(abs(rotated(index, 41:end)));
%     lineToWrite = sprintf('  %d %.2f %.2fsa %.2fia (%.3f; %.2f) at %6.2f in %s on %s\n', ...
%			  dim, actualValue, selfAblatedValue, inteAblatedValue, ...
%			  relativeValAll, residue, time, trackname, side);
     lineToWrite = sprintf('   %d %.2f at %6.2f (%2d:%05.2f) in %s on %s\n', ...
			   dim, actualValue, time, floor(time/60), mod(time,60),  ...
			   trackname, side);
     fprintf(fid, lineToWrite);
    end
end

function indices = findIndicesOfMaxima(dimvec)
  minInterPeakDistance = 200;   % 2 seconds spacing
  numOfExtremesPerTrack = 10;
  indices = ones(numOfExtremesPerTrack,1);

  for j=1:numOfExtremesPerTrack    
    [maxvalue, maxindex] = max(dimvec);
    if maxvalue > 0 
       indices(j) = maxindex;   % else leave it at one
    end 
    startErase= max(maxindex - minInterPeakDistance, 1);
    endErase  = min(maxindex + minInterPeakDistance, length(dimvec));
    dimvec(startErase:endErase) = zeros(endErase-startErase+1, 1);
  end 
end


