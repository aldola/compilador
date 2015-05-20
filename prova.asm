     data         1
     data         1
     ld_int       5
     goto        l1
l2:  ld_int      10
     ret          0
l1:  ld_int       1
     sub          0
     out_int      1
     lt           0
     jmp_false   l1
     call        l2
     halt         0
