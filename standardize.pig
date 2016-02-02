A = LOAD '$input'
        USING PigStorage(';')
        AS (y:double, f1:double, f2:double, f3:double, f4:double, f5:double, f6:double, f7:double, f8:double, 
            f9:double, f10:double);
B = GROUP A ALL;
C = FOREACH B
    GENERATE (double) AVG(A.y) AS ym, (double) AVG(A.f1) AS f1m, (double) AVG(A.f2) AS f2m, (double) AVG(A.f3) AS f3m, 
    (double) AVG(A.f4) AS f4m, (double) AVG(A.f5) AS f5m, (double) AVG(A.f6) AS f6m, (double) AVG(A.f7) AS f7m, 
    (double) AVG(A.f8) AS f8m, (double) AVG(A.f9) AS f9m, (double) AVG(A.f10) AS f10m;
D = FOREACH A
    GENERATE y - (double)C.ym AS y, f1 - (double)C.f1m AS f1, f2 - (double)C.f2m AS f2, f3 - (double)C.f3m AS f3, 
    f4 - (double)C.f4m AS f4, f5 - (double)C.f5m AS f5, f6 - (double)C.f6m AS f6, f7 - (double)C.f7m AS f7, 
    f8 - (double)C.f8m AS f8, f9 - (double)C.f9m AS f9, f10 - (double)C.f10m AS f10;
D2 = FOREACH D
     GENERATE (double) y*y AS y, (double) f1*f1 AS f1, (double) f2*f2 AS f2, (double) f3*f3 AS f3, (double) f4*f4 AS f4, 
    (double) f5*f5 AS f5, (double) f6*f6 AS f6, (double) f7*f7 AS f7,
    (double) f8*f8 AS f8, (double) f9*f9 AS f9, (double) f10*f10 AS f10;
E = GROUP D2 ALL;
F = FOREACH E
    GENERATE (double) AVG(D2.y) AS yv, (double) AVG(D2.f1) AS f1v, (double) AVG(D2.f2) AS f2v, (double) AVG(D2.f3) AS f3v, 
    (double) AVG(D2.f4) AS f4v, (double) AVG(D2.f5) AS f5v, (double) AVG(D2.f6) AS f6v, (double) AVG(D2.f7) AS f7v, 
    (double) AVG(D2.f8) AS f8v, (double) AVG(D2.f9) AS f9v, (double) AVG(D2.f10) AS f10v;
G = FOREACH F
    GENERATE (double) SQRT(F.yv) AS ye, (double) SQRT(F.f1v) AS f1e, (double) SQRT(F.f2v) AS f2e, (double) SQRT(F.f3v) AS f3e, 
    (double) SQRT(F.f4v) AS f4e, (double) SQRT(F.f5v) AS f5e, (double) SQRT(F.f6v) AS f6e, (double) SQRT(F.f7v) AS f7e, 
    (double) SQRT(F.f8v) AS f8e, (double) SQRT(F.f9v) AS f9e, (double) SQRT(F.f10v) AS f10e;
H = FOREACH D
    GENERATE y / (double)G.ye AS y, f1 / (double)G.f1e AS f1, f2 / (double)G.f2e AS f2, f3 / (double)G.f3e AS f3, 
    f4 / (double)G.f4e AS f4, f5 / (double)G.f5e AS f5, f6 / (double)G.f6e AS f6, f7 / (double)G.f7e AS f7, 
    f8 / (double)G.f8e AS f8, f9 / (double)G.f9e AS f9, f10 / (double)G.f10e AS f10;
mean = FOREACH C
        GENERATE (double) ym, (double) f1m, (double) f2m, (double) f3m, (double) f4m, (double) f5m, (double) f6m, 
        (double) f7m, (double) f8m, (double) f9m, (double) f10m;
standarderror = FOREACH G
                 GENERATE (double) ye, (double) f1e, (double) f2e, (double) f3e, (double) f4e, (double) f5e, (double) f6e, 
                (double) f7e, (double) f8e, (double) f9e, (double) f10e ;
STORE H INTO '$output_dataset' USING PigStorage(';') ;
STORE mean INTO '$output_mean' USING PigStorage(';') ;
STORE standarderror INTO '$output_se' USING PigStorage(';') ;