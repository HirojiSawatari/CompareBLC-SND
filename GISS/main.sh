#!/bin/bash -x

begin=1
num=100
rm -rf temp.csv
touch temp.csv
rm -rf temp_tibet.csv
touch temp_tibet.csv
while(($begin<100))
do
  ncl tpr_output.ncl
  ncl test.ncl
  ncl prsn_output.ncl

  # 2 to 3
  cur=`bc << EOF
  scale=2
  2+($begin/$num)
  EOF
  `
  cur2=`bc << EOF
  scale=2
  ($cur/2.65)*2.88  
  EOF
  `  
  cur3=`bc << EOF
  scale=2
  ($cur/2.65)*4.3
  EOF
  `

  cur4=`bc << EOF
  scale=2
  ($cur/2.65)*8.3
  EOF
  `

  cur5=`bc << EOF
  scale=2
  ($cur/2.65)*8.33
  EOF
  `

  cur6=`bc << EOF
  scale=2
  ($cur/2.65)*17.22
  EOF
  `

  str="MSnow[j][k]="${cur}"*out[j][k];"
  str2="193s/.*/"${str}"/"
  sed -i -r ${str2} PDD_V1.0.cpp

  str3="MSnow[j][k]=(0.015*Tjja)+("${cur2}"*out[j][k]);"
  str4="195s/.*/"${str3}"/"
  sed -i -r ${str4} PDD_V1.0.cpp

  str5="MSnow[j][k]="${cur3}"*out[j][k];"
  str6="197s/.*/"${str5}"/"
  sed -i -r ${str6} PDD_V1.0.cpp

  str7="MIce[j][k]="${cur4}"*out[j][k];"
  str8="216s/.*/"${str7}"/"
  sed -i -r ${str8} PDD_V1.0.cpp

  str9="MIce[j][k]=(0.0067*(10-Tjja)*(10-Tjja)*(10-Tjja))+("${cur5}"*out[j][k]);"
  str10="218s/.*/"${str9}"/"
  sed -i -r ${str10} PDD_V1.0.cpp

  str11="MIce[j][k]="${cur6}"*out[j][k];"
  str12="220s/.*/"${str11}"/"
  sed -i -r ${str12} PDD_V1.0.cpp

  g++ -o al.out PDD_V1.0.cpp -lgsl -lgslcblas -L$GSL_LD -lm
  ./al.out
  ncl blc_out.ncl
  # sed -i "$s/.*/"${cur}"/" temp.csv
  # echo "0"${cur}"," >> temp.csv

  ncl sftlf_out.ncl

  ncl snd_CCSM_out.ncl
  ncl avg_snd.ncl
  ncl avg_blc.ncl
  ncl data_out.ncl

  ncl comp_ccsm.ncl
  comp=$(sed -n 1p ncltmp.txt)
  echo ${comp}
  echo ${cur}","${comp} >> temp.csv

  ncl comp_ccsm_tibet.ncl
  comp=$(sed -n 1p ncltmp_tibet.txt)
  echo ${comp}
  echo ${cur}","${comp} >> temp_tibet.csv

  begin=$(($begin+1))
done
