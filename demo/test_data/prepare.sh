perl -MCwd -ne 'chomp; my $pwd = getcwd; my @t = split /\t/; print "$t[0]\t$pwd/$t[1]\n";' tf.chipseq.lst.origin > tf.chipseq.lst

perl -MCwd -ne 'chomp; my $pwd = getcwd; my @t = split /\t/; print "$t[0]\t$pwd/$t[1]\n";' gene.expr.lst.origin > gene.expr.lst
