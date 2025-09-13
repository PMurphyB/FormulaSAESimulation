function trackTable = dxf_to_track(filename)
% dxf_to_track - Reads a DXF file and extracts line/arc info for track simulation
% Input: filename (string) - path to DXF file
% Output: trackTable (table) - columns: Type | Length | ArcLength | Radius

    % Read DXF as text
    fid = fopen(filename, 'r');
    if fid == -1
        error("Could not open file: %s", filename);
    end
    raw = textscan(fid, '%s', 'Delimiter','\n');
    fclose(fid);
    raw = raw{1};

    % Prep storage
    Types = {};
    Lengths = [];
    ArcLengths = [];
    Radii = [];

    i = 1;
    while i <= numel(raw)
        line = strtrim(raw{i});

        % ---------------- LINE ----------------
        if strcmp(line, 'LINE')
            % DXF gives group codes: 10/20 = start x,y ; 11/21 = end x,y
            x1 = str2double(raw{i+2});
            y1 = str2double(raw{i+4});
            x2 = str2double(raw{i+6});
            y2 = str2double(raw{i+8});

            segLength = sqrt((x2-x1)^2 + (y2-y1)^2);

            Types{end+1,1} = "Straight";
            Lengths(end+1,1) = segLength;
            ArcLengths(end+1,1) = 0;
            Radii(end+1,1) = NaN;

        % ---------------- ARC ----------------
        elseif strcmp(line, 'ARC')
            % Group codes: 10/20 = center x,y ; 40 = radius ; 50/51 = start/end angles (deg)
            cx = str2double(raw{i+2});
            cy = str2double(raw{i+4});
            r  = str2double(raw{i+6});
            startAng = str2double(raw{i+8});
            endAng   = str2double(raw{i+10});

            % Handle wrapping if needed
            sweep = endAng - startAng;
            if sweep < 0
                sweep = sweep + 360;
            end

            arcLen = deg2rad(sweep) * r;

            Types{end+1,1} = "Curve";
            Lengths(end+1,1) = 0;
            ArcLengths(end+1,1) = arcLen;
            Radii(end+1,1) = r;
        end

        i = i + 1;
    end

    % Build table
    trackTable = table(Types, Lengths, ArcLengths, Radii, ...
        'VariableNames', {'Type','Length','ArcLength','Radius'});
end
