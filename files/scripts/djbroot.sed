# djbroot.sed
# convert internic named.root file for djbdns
# wcm, 2004.01.12 - 2004.01.12
# ===
/^$/d
/^ *$/d
/^;/d
/^\./d
s/[A-Z]\.ROOT-SERVERS\.NET\. *.*A *//
### that's all, folks!
