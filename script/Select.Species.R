# Script Description --------------------
# This script prepares the reads a csv file of threatened tree species, allows the user
# to input search terms/strings to select a species of interest, and save the result as
# a csv file.


# Read Data File ------------------------
# Note:change file path to your working directory
data <- read.csv(file="Geoferenced_threatenedforesttreespecies.csv", header=TRUE, sep=",")

# Select Species ------------------------
polillo_cm <- subset(data, Species=="Cinnamomum mercadoi" & Source=="Clements, 2001", 
                     select=c(2,10:11))

# Save Results to File ------------------
write.csv(polillo_cm, file="polillo_cm.csv", row.names=FALSE)