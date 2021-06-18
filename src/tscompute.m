function tscompute(in, out, hctsa)
    % Load timeseries and save in hctsa format
    timeSeriesData = dlmread(in)';
    labels = arrayfun(@(x) char(string(x)),1:size(timeSeriesData, 1), 'un', 0);
    keywords = labels;
    [folder, basefilename, extension] = fileparts(in);
    tsfile = fullfile(folder, horzcat(basefilename, '.mat'));
    if isempty(folder)
        folder = './';
    end
    hctsafile = [tempname(folder), '.mat'];
    save(tsfile, 'timeSeriesData', 'labels', 'keywords')
    
    % Run hctsa
    hm = pwd();
    cd(hctsa)
    startup
    cd(hm)
    TS_Init(tsfile, 'INP_mops_catch22.txt','INP_ops_catch22.txt', false, hctsafile);
    TS_Compute(false, [], [], 'bad', hctsafile, false);
    
    % Save features back to a file
    load(hctsafile, 'TS_DataMat', 'Operations')
    ops = Operations.Name;
    F = arrayfun(@(x) x, TS_DataMat, 'un', 0);
    slra = horzcat(ops, F');
    if isfile(out)
        delete(out);
    end
    writecell(slra, out);
    
    % Clean up
    delete(hctsafile);
    delete(tsfile);
end