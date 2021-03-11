clear
clc

fid = fopen('net.summary.512');

tline = fgetl(fid);
i = 1;
max_sel = -1;
i_max_sel = -1;
max_p = -1;
i_max_p = -1;
max_n = -1;
i_max_n = -1;
max_mr = -1;
i_max_mr = -1;

while ischar(tline)
    %disp(tline)
    if (i>4)
        str = split(tline);
        if contains(str(7), 'SEL')
            t1 = str2double(cell2mat(str(2)));
            t2 = str2double(cell2mat(str(3)));
            s = t1 + t2;
            if s > max_sel
                max_sel = s;
                i_max_sel = sscanf(cell2mat(str(7)),"SEL<%d>");
            end
        elseif contains(str(7), 'P')
            t1 = str2double(cell2mat(str(2)));
            t2 = str2double(cell2mat(str(3)));
            s = t1 + t2;
            if s > max_p
                max_p = s;
                i_max_p = sscanf(cell2mat(str(7)),"P<%d>");
            end
        elseif contains(str(7), 'N')            
            t1 = str2double(cell2mat(str(2)));
            t2 = str2double(cell2mat(str(3)));
            s = t1 + t2;
            if s > max_n
                max_n = s;
                i_max_n = sscanf(cell2mat(str(7)),"N<%d>");
            end
        elseif contains(str(7), 'MR')
            t1 = str2double(cell2mat(str(2)));
            t2 = str2double(cell2mat(str(3)));
            s = t1 + t2;
            if s > max_mr
                max_mr = s;
                i_max_mr = sscanf(cell2mat(str(7)),"P<%d>");
            end
        elseif contains(str(7), 'VSS')
            t1 = str2double(cell2mat(str(2)));
            t2 = str2double(cell2mat(str(3)));
            s = t1 + t2;
            fprintf("VSS: TOTAL C + CC: %e\n", s);
        end             
    end
    tline = fgetl(fid);
    i=i+1;
end

fclose(fid);

fprintf("WORST SEL<%d>: TOTAL C + CC: %e\n", i_max_sel, max_sel);
fprintf("WORST P<%d>: TOTAL C + CC: %e\n", i_max_p, max_p);
fprintf("WORST N<%d>: TOTAL C + CC: %e\n", i_max_n, max_n);
fprintf("WORST MR<%d>: TOTAL C + CC: %e\n", i_max_mr, max_mr);