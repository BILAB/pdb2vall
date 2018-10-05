#!/bin/bash

# This script is made to add a line 'the number of sequences better than 1.0e-05: xxx' into 'hoge.2.chk' file
# so that 'blastplus_pdb2vall.py' script will get 'n_ali' number from the 'hoge.2.chk' file to write it in 'hoge.vall' file at later.
# This script will be used only when 'blastplus_pdb2vall.py' is called.

if type gsed 2>/dev/null 1>/dev/null;then
  SED=gsed
else
  SED=sed
fi

input=$1

if [[ ! -f ${input}.2.blast ]];then
  echo "${input}.2.blast is not found. exit."
  exit 1
fi

# check whether ${input}.2.blast is generated by psiblast (not blastp) or not.
head -n 1 ${input}.2.blast | grep "PSIBLAST" 2>/dev/null 1>/dev/null
if test $? -ne 0;then
  echo "${input}.2.blast may be generated by legacy blastp. exit."
  exit 1
fi

range1=`grep "Sequences used in model and found again:" ${input}.2.blast -n | sed -e 's/:.*//g'`
range2=`grep "Sequences not found previously or not previously below threshold:" ${input}.2.blast -n | sed -e 's/:.*//g'`
rangelast=()
rangelast+=(`grep "Lambda" ${input}.2.blast -n | sed -e 's/:.*//g'`)

A=`expr $range2 - $range1 - 1`

# num1 is the number of sequences present between "Sequences used in model and found again:" and "Sequences not found previously or not previously below threshold" lines
num=`grep "Sequences used in model and found again:" -A ${A} ${input}.2.blast | grep "  *" | wc -l`
num1=`expr $(($num)) - 1`

B=`expr ${rangelast[2]} - $range2 - 1`

# num2 is the number of sequences present between "Sequences not found previously or not previously below threshold" and "Lambda" lines
num=`grep "Sequences not found previously or not previously below threshold:" -A ${B} ${input}.2.blast | grep "\s\s.*" | wc -l`
num2=$(($num))
if [[ $num -eq 0 ]];then
  num2=0
fi

# sum is the total number of sequences written in hoge.2.chk
sum=`expr $num1 + $num2`

# delete if "Number of sequences ..." is already present
${SED} -i -e "/^Number of sequences better than 1.0e-05/d" ${input}.2.blast
echo "Number of sequences better than 1.0e-05: ${sum}" >> ${input}.2.blast