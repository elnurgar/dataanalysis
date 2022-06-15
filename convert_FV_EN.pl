#!/usr/bin/perl
use strict;
use warnings;

print("Salut \n");

my @files;
my @tmpfiles = glob("*.mgf");

print("List of mgf and mzXML files in folder \n");

foreach my $f (@tmpfiles) {
    $f=~s/\.mgf$//;
    print("$f.mgf\n$f.mzXML\n");
    push @files, $f;
}

print("Do you want to continue (Y/N) ? ");

my $userword = <STDIN>;
chomp $userword;
if ($userword eq "N" || $userword eq "n")
{
  exit 0;
};

foreach my $file (@files)
{
  my $mgf = $file.".mgf";
  my $mz = $file.".mzXML";
  my $newfile= $file."_modified.mzXML";

  my @val;

  if( ! open(my $fd,'<',$mgf) ) {
     exit(1);
  }
  else{
    #on récupère les lignes qui nous intéressent dans le fichier mgf
    my $strms;
    my $strpep;
    while( defined(my $l = <$fd> ) ) {
     chomp $l;
     #print "$. : $l\n";

     if($l=~m/^###MSMS:/)
     {
       my @MS = split(':', $l);
       $strms=$MS[1];
       #print $strms."\n";
     }
     if($l=~m/^PEPMASS/)
     {
       my @PEPtmp = split('=', $l);
       my @PEP= split(' ',$PEPtmp[1]);
       $strpep=$PEP[0];
       #print $strpep."\n";
       @val[$strms]=$strpep;
     }



    }

    #print @val,"\n";

    #on créer le fichier modified
    open my $fl, '>' ,$newfile;

    #on ouvre le fichier mz
    if(! open(my $file,'<',$mz) ) {
       exit(1);
    }
    else{
      #on boucle dans les lignes
      my $scan;
      my $prec;

      while( defined(my $l2 = <$file> ) ) {
       chomp $l2;

       my $newl=$l2;
       #print $l2."\n";
       #on récupère les valeurs pour chaque ligne
       if($l2=~m/<scan num=/) #TODO le pronlème est là le if ne match pas
       {
         my @scanl=split('<scan num=',$l2);
         my @scantmp=split('"',$scanl[1]);
         $scan=$scantmp[1];
         #print $scan."\n";
       }

       if($l2=~m/<precursorMz precursorIntensity/)
       {
         my @precl=split('>',$l2);
         my @prectmp=split('<',$precl[1]);
         $prec=$prectmp[0];

         #on modifie la ligne au bon endroit
         if($val[$scan])
         {
           print("scan - ".$scan."\n");
           print("actual value of XML - ".$prec."\n");
           print("new value of XML - ".$val[$scan]."\n");

           $newl=$precl[0].">".$val[$scan]."<".$prectmp[1].">";


         }

       }

      print $fl $newl."\n";



      }
    }

    close $fd;
    close $fl;

  }
}
