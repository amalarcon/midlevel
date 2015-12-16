function graphPf(directory, audioFile, side, times, featurespecfile)

% graph prosodic features
% Nigel Ward, UTEP, April 2015

trackspec.side = side;
trackspec.filename = audioFile;
trackspec.path = [directory '/' audioFile];
trackspec.directory = [directory '/'];  % to enable finding the cache

featurelist = getfeaturespec(featurespecfile);
[ignore, monster] = makeTrackMonster(trackspec, featurelist);

for time = times
  figure()   % so the next one doesn't overwrite this feature 
  graphname = sprintf('prosody around %.2f for %s track of %s using %s\n', ...
        time, side, audioFile, featurespecfile);  
  patvis(monster(floor(time *100),:), featurespecfile, graphname, false);
end

end

% test with 
%  addpath('../voicebox');
%  graphPF('../minitest', '21d.au', 'l', [10], '../minitest/minicrunch.fss');
%  graphPF('../minitest', '21d.au', 'l', [10], '../fulltest/april.fss');
%  cd ../PaolaRecordings
%  graphPF('EnglishL1L2', 'nn001.wav', 'l', [547.5], 'al_corrected.fss')