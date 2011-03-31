-- robin andersson
-- Gain levels from 0 to -60
  for i=0:31 a(i+1)=db2mag(i*2-62); end
  dec2bin(a*2047,12)