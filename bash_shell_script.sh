## Putting all our mcrAgenes and hsp70gene into their own files (with for loop)

	# mcrAgene
for i in ./ref_sequences/mcr*.fasta
do
cat $i >> mcrAgene.fasta
done
	# hsp70gene
for i in ./ref_sequences/hsp*.fasta
do
cat $i >> hsp70gene.fasta
done

## Alligning reference sequences (with muscle)

	# mcrAgene
./muscle -in mcrAgene.fasta -out MCRA_Muscle.afasta

	# hsp70gene
./muscle -in hsp70gene.fasta -out HSP_Muscle.afasta

## Building hmm profiles for the  mcrAgene & hsp70gene

	# mcrAgene
./hmmbuild mcrAgene.hmm MCRA_Muscle.afasta

	# hsp70gene
./hmmbuild hsp70gene.hmm HSP_Muscle.afasta


## initializing the final table
echo "
HSP70 & mcrA output
" > final.tbl

## Searching the proteomes for mcrAgene and hsp70gen (with hmmsearch)
for genes in ./proteomes/*.fasta
do
./hmmsearch --tblout $genes.hsp70gene.tbl hsp70gene.hmm $genes
./hmmsearch --tblout  $genes.mcrAgene.tbl mcrAgene.hmm $genes
done

## counting all the times we found gene matches
for genes in ./proteomes/*.fasta
do
x=$(echo $genes | sed -E 's/[^0-9]//g')
hsp=$(cat $genes.hsp70gene.tbl | grep "HSP_Muscle" | uniq | wc -l)
mcrA=$(cat $genes.mcrAgene.tbl | grep "MCRA_Muscle" | uniq | wc -l)
echo "Proteome" $x $hsp "HSP" $mcrA "mcrA" >> final.tbl
done

## saving all the genes that are considered candidates
grep -v ' 0 ' final.tbl > candidates.txt

## Thank you :)))
