function writeCorrelations(cmatrix, featurelist, outdir, filename);
% helps discover some key information in a correlation matrix
% for each feature, shows the other features that correlate well
%   with it, and one that is pretty much uncorrelated.
% sample use: 
%   cmatrix = corrcoef(fetch_and_preen('toyFiles/dummyFileList.fnl'));
%   [junk featurelist] = getfeaturespec('toyFiles/dummyCrunchSpech.txt');
%   scan_correlations(cmatrix, featurelist);
% or we can do this on an epfile, loaded with 
%   a = importdata('....')
%   data = a.data

[outdir filename];
fd = fopen([outdir filename], 'w');

for columni = 1:length(cmatrix)
  [sortedValues,sortIndex] = sort(cmatrix(columni,:), 'descend');
  topIndices = sortIndex(1:4);
  bottomIndex = sortIndex(length(cmatrix));

  fprintf(fd, 'for feature #%d %s, ', columni, featurelist(columni).abbrev);
  fprintf(fd, '   the three most correlated features are ');
  for ix = 1:4
    topf = topIndices(ix);
    fprintf(fd, '\n     #%d %s   at %.2f', ...
            topf, featurelist(topf).abbrev, cmatrix(columni,topf));
  end
  fprintf(fd, '\n   the least correlated feature is: ');
bx = bottomIndex;
  fprintf(fd, '\n       #%d %s    at %.2f\n', ...
	  bx, featurelist(bx).abbrev, cmatrix(columni,bx));
end