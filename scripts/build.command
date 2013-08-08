#!/bin/sh
debug=''
nolog=''
bibtex='bibtex'
latex='xelatex'

if [[ $debug -eq "1" ]]; then
  nolog=" 2>/dev/null"
	nonstop="-interaction=nonstopmode"
	latex="$latex $nonstop"
fi
set_basedir() {
  BASEDIR=$(dirname $0)
  cd $BASEDIR
  cd ../chapters
}

# convert all .md files in the chapters directory to .docx
create_docx() {
  for i in *.md ; do

    # generate Word file
    filename_wd=${i/%???/}.docx
    pandoc $i \
           --from=markdown+tex_math_dollars+tex_math_single_backslash+implicit_figures \
           --to=docx \
           --reference-docx="derivatives/word/style.docx" \
           --bibliography="references.bib" \
           -o derivatives/word/$filename_wd

  done
}

# convert all .md files in the chapters directory to .tex
create_tex() {
  for i in *.md ; do

    filename_tex=${i/%???/}.tex
    pandoc $i \
	  --from=markdown+tex_math_dollars+tex_math_single_backslash+implicit_figures \
	  --to=latex \
	  --latex-engine="$latex"\
	  --chapters \
	  --bibliography="references.bib" \
	  --natbib \
	  -o derivatives/tex/$filename_tex
  done
}

cleanup_tex() {
  cd derivatives/tex/
  for i in *.tex ; do
  pwd
    echo "mv $i .$i"
    echo "awk -f .tst.awk .$i > 							   $i $nolog"
    sed -i='' 's/\(\\\includegraphics{\)\([^}]*\)\(}\)/\\\makebox[\\\textwidth]{\1\2\3}/g' $i $nolog
    #sed -i '' 's/\\\includegraphics{/\\\makebox[\\\textwidth][c]{\\\includegraphics{/g'   $i $nolog
    #sed -i '' 's/\\\caption{/}\\\caption{/g' 						   $i $nolog
    #rm .$i
  done
  cd ../..
}

#convert  all .md in frontmatter folder
create_frontmatter() {
  cd ../frontmatter

  for i in *.md ; do
    filename_tex=${i/%???/}.tex		$nolog
    pandoc -o $filename_tex $i		$nolog
  done

  for i in *.tex ; do
    mv $i .$i
    awk -f .tst.awk .$i > $i		$nolog
    rm .$i
done
}

compile() {
  cd ..
  $latex  dissertation			$nolog
  $bibtex bibtex dissertation		$nolog
  $latex  dissertation			$nolog
  $latex  dissertation			$nolog
}


cleanup() {
  # hide the log
  mv "dissertation.log" ".logged"

  # kill temp files
  rm "./frontmatter/thanks.tex"
  rm "./frontmatter/abstract.tex"
  rm "./frontmatter/dedication.tex"
  rm "./frontmatter/personalize.tex"

  # delete all the junk files
  find . -name "*.log" -exec rm -rf {} \;
  find . -name "*.aux" -exec rm -rf {} \;
  find . -name "*.toc" -exec rm -rf {} \;
  find . -name "*.blg" -exec rm -rf {} \;
  find . -name "*.bbl" -exec rm -rf {} \;
  find . -name "*.out" -exec rm -rf {} \;
  find . -name "*.brf" -exec rm -rf {} \;
  find . -name "*.tex-e" -exec rm -rf {} \;
  find . -name "*.lof" -exec rm -rf {} \;
  find . -name "*.lot" -exec rm -rf {} \;
  find . -name "*.loa" -exec rm -rf {} \;
}

######################## MAIN()
  set_basedir
  create_docx
  create_tex
  cleanup_tex
  create_frontmatter
  compile
  cleanup
