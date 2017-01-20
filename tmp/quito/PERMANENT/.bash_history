r.in.gdal input=quito.tif  output=quito
r.recode input=quito output=quito_urban rules=- << EOF
0:0:2
1:12:0
14:*:0
13:13:1
EOF

r.clump -dg quito out=urban_lc
ls -l
openev quito.tif 
