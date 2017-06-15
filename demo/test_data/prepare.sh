perl -MCwd -ne 'chomp; my $pwd = getcwd; my @t = split /\t/; print "$t[0]\t$pwd/TfBindingProfiles/$t[1]\n";' ./TfBindingProfiles/tf.chipseq.lst.origin > ./TfBindingProfiles/tf.chipseq.lst

perl -MCwd -ne 'chomp; my $pwd = getcwd; my @t = split /\t/; print "$t[0]\t$pwd/GeneExpressionProfiles/$t[1]\n";' ./GeneExpressionProfiles/gene.expr.lst.origin > ./GeneExpressionProfiles/gene.expr.lst
