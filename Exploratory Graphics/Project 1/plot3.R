# r-script for plot3

# Date: Date in format dd/mm/yyyy
# Time: time in format hh:mm:ss
# Global_active_power: household global minute-averaged active power (in kilowatt)
# Global_reactive_power: household global minute-averaged reactive power (in kilowatt)
# Voltage: minute-averaged voltage (in volt)
# Global_intensity: household global minute-averaged current intensity (in ampere)
# Sub_metering_1: energy sub-metering No. 1 (in watt-hour of active energy). It corresponds to the kitchen, containing mainly a dishwasher, an oven and a microwave (hot plates are not electric but gas powered).
# Sub_metering_2: energy sub-metering No. 2 (in watt-hour of active energy). It corresponds to the laundry room, containing a washing-machine, a tumble-drier, a refrigerator and a light.
# Sub_metering_3: energy sub-metering No. 3 (in watt-hour of active energy). It corresponds to an electric water-heater and an air-conditioner.

# read data
masterDF <- read.csv("household_power_consumption.txt", sep=";", stringsAsFactor = FALSE)

x <- paste(masterDF$Date, masterDF$Time)
z <- strptime(x, "%d/%m/%Y %H:%M:%S")
zlow <- strptime("01/02/2007 00:00:01", "%d/%m/%Y %H:%M:%S")
zhigh <- strptime("02/02/2007 23:59:59", "%d/%m/%Y %H:%M:%S")

masterDF$zbool <- (z>=zlow & z<= zhigh)
masterDF$dt <- z

DF <- masterDF[masterDF$zbool==TRUE,]
DF <- DF[!is.na(DF$dt),]
# cleanup unnecessary data
rm(masterDF, x, z)
rm(z1, zbool, zhigh, zlow)
# generate final data frame
DF <- data.frame(DF$dt, as.numeric(DF$Global_active_power), as.numeric(DF$Global_reactive_power), as.numeric(DF$Voltage), as.numeric(DF$Global_intensity), as.numeric(DF$Sub_metering_1), as.numeric(DF$Sub_metering_2), as.numeric(DF$Sub_metering_3))

names(DF) <- c("dt", "Global_active_power", "Global_reactive_power", "Voltage", "Global_intensity", "Sub_metering_1", "Sub_metering_2", "Sub_metering_3")
# ready for plotting
png("plot3.png", width = 480, height = 480)
plot(DF$dt, DF$Sub_metering_1, type="n", xlab = "", ylab="Energy sub metering")
lines(DF$dt, DF$Sub_metering_1, col="black",lwd=1) 
lines(DF$dt, DF$Sub_metering_2, col="red", lwd=1)
lines(DF$dt, DF$Sub_metering_3, col="blue",lwd=1)
legend("topright", legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lwd=1,
                          col=c("black", "red", "blue"))
dev.off()