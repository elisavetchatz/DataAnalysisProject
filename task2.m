%Group40Exe2

data = readtable('TMS.xlsx');

% Extract relevant columns for ED duration with different coil codes
ED_coil_one = data.EDduration(strcmp(data.CoilCode, '1'));
ED_coil_zero = data.EDduration(strcmp(data.CoilCode, '0'));

% Remove missing values to be safe 
ED_coil_one = ED_coil_one(~isnan(ED_coil_one));
ED_coil_zero = ED_coil_zero(~isnan(ED_coil_zero));






