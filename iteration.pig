
%declare gamma $gam
%declare lambda $lam
%declare nb_observation $count

INPUTFILE = LOAD '$normalizedinput'
        USING PigStorage(';')
        AS (y:double, f1:double, f2:double, f3:double, f4:double, f5:double, f6:double, f7:double, f8:double, 
            f9:double, f10:double);
A = RANK INPUTFILE;

W = LOAD '$previousWeights'
        USING PigStorage(';')
        AS (w1:double, w2:double, w3:double, w4:double, w5:double, w6:double, w7:double, w8:double, 
            w9:double, w10:double);

B = CROSS A, W;
 
D = FOREACH B GENERATE $0 as id, 
                      y as y,
                      (f1,f2,f3,f4,f5,f6,f7,f8,f9,f10) as vector,
                      FLATTEN({(f1,w1,1),(f2,w2,2),(f3,w3,3),(f4,w4,4),(f5,w5,5),(f6,w6,6),(f7,w7,7),
                               (f8,w8,8),(f9,w9,9),(f10,w10,10)});
E = FOREACH D GENERATE id as id, 
                      y as y,
                      vector as vector,
                      TOTUPLE($3,$4,$5) as product;
F = FOREACH E GENERATE id as id, 
                      y as y,
                      vector as vector,
                      product as product,
                      product.$0 * product.$1 as prod; 
G = GROUP F by (id, y, vector);
H = FOREACH G GENERATE group.id as id, 
                       group.y as y,
                       group.vector as vector,
                       SUM(F.prod) - group.y as diff;
                
I = FOREACH H GENERATE id as id,
                       y as y,
                       diff as diff,
                       FLATTEN({(vector.$0,1),(vector.$1,2),(vector.$2,3),(vector.$3,4),(vector.$4,5),
                               (vector.$5,6),(vector.$6,7),(vector.$7,8),(vector.$8,9),(vector.$9,10)});
J = FOREACH I GENERATE id as id,
                       y as y,
                       diff * $3 as gradient,
                       $4 as dim;                        
K = GROUP J by dim;
L = FOREACH K GENERATE group as dim,
                       SUM(J.gradient)/$nb_observation as gradient;
W2 = FOREACH W GENERATE FLATTEN({(w1,1),(w2,2),(w3,3),(w4,4),(w1,5),(w1,6),(w1,7),(w1,8),(w1,9),(w1,10)});
M = JOIN L BY dim, W2 BY $1;
N = FOREACH M GENERATE $0 as dim,
                      (CASE
                        WHEN $2 - $gamma * $1 > $lambda THEN $2 - $gamma * $1 - $lambda
                        WHEN ABS($2 - $gamma * $1) <= $lambda THEN 0
                        WHEN $2 - $gamma * $1 < - $lambda THEN $2 - $gamma * $1 + $lambda
                       END) as w;
N2 = GROUP N ALL;
N3 = FOREACH N2 GENERATE FLATTEN(BagToTuple(N.w));
    
O = JOIN N BY dim, W2 BY $1;
P = FOREACH O GENERATE ABS($2 - $1) AS conv;
Q = GROUP P ALL;
R = FOREACH Q GENERATE SUM(P.conv) AS conv;

STORE N3 INTO '$newWeights' USING PigStorage(';') ;
STORE R INTO '$conv' USING PigStorage(';') ;