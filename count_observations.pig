A = LOAD '$input'
        USING PigStorage(';')
        AS (y:double, f1:double, f2:double, f3:double, f4:double, f5:double, f6:double, f7:double, f8:double, 
            f9:double, f10:double);
B = GROUP A ALL;
C = FOREACH B GENERATE COUNT(A);
STORE C
INTO '$output'
USING PigStorage(';') ;