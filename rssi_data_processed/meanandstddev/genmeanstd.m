% Generate mean and std for all cells
close all;

% Constants
ap1_fn = '/Users/Abhi/Documents/Learning/Courses/Delft/2013-2014/p4/IN4254-SmartPhoneSensing/Markt/rssi_data_processed/ipad1.txt  ';
ap2_fn = '/Users/Abhi/Documents/Learning/Courses/Delft/2013-2014/p4/IN4254-SmartPhoneSensing/Markt/rssi_data_processed/ipad2.txt  ';
ap3_fn = '/Users/Abhi/Documents/Learning/Courses/Delft/2013-2014/p4/IN4254-SmartPhoneSensing/Markt/rssi_data_processed/iphone1.txt';
filenum = [2:4];

for i=filenum(3):filenum(3)
  out_file = fopen(ap3_fn, 'w');
  fprintf(out_file,'Mean;Standard Deviation\n');
  fprintf(out_file, '%f;%f\n', double(mean(cell1(:,i))), double(std(cell1(:,i))));
  fprintf(out_file, '%f;%f\n', mean(cell2(:,i)), std(cell2(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell3(:,i)), std(cell3(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell4(:,i)), std(cell4(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell5(:,i)), std(cell5(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell6(:,i)), std(cell6(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell7(:,i)), std(cell7(:,i)));
  fprintf(out_file, '%f;%f\n', mean(cell8(:,i)), std(cell8(:,i)));
  fclose(out_file);
end