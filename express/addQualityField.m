

var = FechnerExpress;

fnames = {var.file}';

qualityString = regexpi(fnames,'(excellent|good|bad|ugly|problemFiles)','match');

for i=1:numel(fnames)
    var(i).qualityString = regexpi(fnames{i},'(excellent|good|bad|ugly|problemFiles)','match');
    switch char(qualityString{i})
        case 'ProblemFiles'
            var(i).quality = 0;
        case 'ugly'
            var(i).quality = 1;
        case 'bad'
            var(i).quality = 2;
        case 'good'
            var(i).quality = 3;
        case 'excellent'
            var(i).quality = 4;
   end
            
end
