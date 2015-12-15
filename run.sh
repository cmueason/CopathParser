# argument 1 is the input file
# if argument 1 is not given, use "input.txt"
if [ "$#" -ge 2 ]
then
  myfile=$1
else
  myfile=input.txt
  echo "Using input.txt as the input.."
fi
  
echo "Processing file $myfile. Program will not function if $myfile does not exist!"
echo "Calling perl to change all \\r to \\r\\n (newlines).."
perl -ne 's/\r/\r\n/g; s/Gross Description/\nGrossDescription/; print;' < $myfile > .mytemp 

echo "Calling ruby to process text file and generate csv output.txt.."
ruby process.rb .mytemp > output.csv

echo "Please take a peek at the output:"
echo "---"
head -n 7 output.csv | tail -n 5

echo "Cleaning up.."
rm -f .mytemp

exit 0
