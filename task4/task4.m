%Group40Exe4

file_path = '../TMS.xlsx';
setup_numbers = 1:6;

for setup_num = setup_numbers
    check_corr(file_path, setup_num, 0.05);
end