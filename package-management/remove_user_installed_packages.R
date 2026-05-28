# create a list of all installed packages
instpack<- as.data.frame(installed.packages())
head(instpack)
# if you use MRO, make sure that no packages in this library will be removed
instpack<- subset(instpack, !grepl("MRO", instpack$LibPath))
# we don't want to remove base or recommended packages either\
instpack<- instpack[!(instpack[,"Priority"] %in% c("base", "recommended")),]
# determine the library where the packages are installed
path<- unique(instpack$LibPath)
# create a vector with all the names of the packages you want to remove
pkgs.to.remove<- instpack[,1]
head(pkgs.to.remove)
# remove the packages
sapply(pkgs.to.remove, remove.packages, lib = path)