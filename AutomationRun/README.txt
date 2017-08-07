# deliver sequel
sh deliver_pacbio.sh 02_test_sequel_2017_08_01_fn_ln trans
#RSII
sh deliver_pacbio.sh 01_test_rsii_2017_06_25_fn_ln trans


#A more detailed description is available at:
https://github.uio.no/NSC-CEES/postSequencigDatahandling/wiki

#Alternative with piping of output
#sequel
sh deliver_pacbio.sh 02_test_sequel_2017_08_01_fn_ln trans\
| tee 1> log/deliv_01_test_sequel_2017_08_01_fn_ln_1.out \
2> log/deliv_01_test_sequel_2017_08_01_fn_ln_fn_ln_1.err

#RSII
sh deliver_pacbio.sh  01_test_rsii_2017_06_25_fn_ln trans\
| tee 1> log/deliv_01_test_rsii_2017_06_25_fn_ln_1.out \
2> log/deliv_01_test_rsii_2017_06_25_fn_ln_1.err


#run script without transfer md5sum and email
sh deliver_pacbio.sh 02_test_sequel_2017_08_01_fn_ln no_trans
