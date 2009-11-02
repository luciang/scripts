#!/bin/sh

#Acest script transforma scrierea pre-92 in post-92
#Copyright I. M. Ciobica si E. Petrisor, GPL, 2005
#Adaptat pentru sh de Fita Adrian, 2005

#Intii se verifica daca argumentul exista
if [ "$#" != 1 ]; then
   echo "Usage: $(basename $0) arg1"
   exit 1
fi

#Apoi se verifica daca fisierul exista
if [ ! -f "$1" ]; then
   echo "Usage: $(basename $0) arg1"
   echo "with arg1 a (text) file."
   exit 2
fi

#Back-up?
cp -p "$1" "$1.bak"

#Acum cautam ce fel de codare avem, iso-8859-16 sau UTF-8?
#Comanda file nu este de incredere.
abreve_iso8859=$(grep -c 'ă' "$1")
abreve_utf8=$(grep -c 'Ä' "$1")

#echo "$abreve_iso8859 'a_breve' non-UTF-8 and $abreve_utf8 'a_breve' UTF-8."

if [ $abreve_utf8 -gt 0 -a $abreve_iso8859 -eq 0 ]; then
   #avem UTF-8
   echo "UTF-8 text."
   cat "$1.bak" | sed ':a;s/\([a-zA-Z]\)ĂŽ\([a-zA-Z]\)/\1Ă˘\2/;ta' | \
              sed ':a;s/\([A-Za-z]\)Ă\([A-Za-z]\)/\1Ă\2/;ta' | \
              sed ':a;s/\(\(R\|r\)e\|\(N\|n\)e\|\(D\|d\)e\(s\|z\)\|\(P\|p\)re\|\(P\|p\)ost\)Ă˘/\1ĂŽ/;ta' | \
              sed ':a;s/\(RE\|\NE\|DE\(S\|Z\)\|PRE\|POST\)Ă/\1Ă/;ta' | \
              sed ':a;s/\([Ss]\)ĂŽnt/\1unt/;ta' | \
              sed ':a;s/\([Ss]\)Ă˘nt/\1unt/;ta' | \
              sed 's/SĂNT/SUNT/g' | sed 's/SĂNT/SUNT/g' > "$1"
   exit 0
fi

if [ $abreve_iso8859 -gt 0  -a $abreve_utf8 -eq 0 ]; then
   #avem iso-8859-ceva, ceva=2,16
   echo "ISO-8858-x text."
   cat "$1.bak" | sed ':a;s/\([a-zA-Z]\)î\([a-zA-Z]\)/\1â\2/;ta' | \
                sed ':a;s/\([A-Za-z]\)Î\([A-Za-z]\)/\1Â\2/;ta' | \
                sed ':a;s/\(\(R\|r\)e\|\(N\|n\)e\|\(D\|d\)e\(s\|z\)\|\(P\|p\)re\|\(P\|p\)ost\)â/\1î/;ta' | \
                sed ':a;s/\(RE\|\NE\|DE\(S\|Z\)\|PRE\|POST\)Â/\1Î/;ta' |\
                sed ':a;s/\([Ss]\)[îâ]nt/\1unt/;ta' | \
                sed 's/S[ÎÂ]NT/SUNT/g' > "$1"
   exit 0
fi

#Asta a fost. "diff $1 $1.bak"?


#Aici se iese daca "ă" nu a fost detectat nici intr-o varianta.
echo "$1 file contains no diacritics. Or 'a with breve' exists in both variants UTF-8 and non-UTF-8. "
exit 10
