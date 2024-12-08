replace text in a file:
`find . -name "*.hs" -type f -exec sed -i 's/<oldname>/<newname>/g' {} \;``

man, tldr - documentation 
echo $PATH 
cat - concactenate 
tee - read and write standard IO, files 
touch - update files timestamp 
chmod - change permissions 
diff - differences 
grep - search patterns 
date - print date 
find 

IO redirection: 
$  > file - write to file    
< file - read from file 
$ >> append to file 
| - chain programs 
sudo does not pipe through chains 

Scripting: 
var assignment 
' for literal string 
" for delimited string 
bash supports if, case, while, for, functions 
Short circuting operations: &&(and) ||(or) 

$(command) - command subsitution (edited)

