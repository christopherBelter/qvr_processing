process_qvr_data <- function(the_data, id_column = "Appl.Id") {
	the_data <- unique(the_data)
	if (sum(duplicated(the_data[,id_column])) > 0) {
		split_data <- split(the_data, the_data[,id_column])
		tmp <- which(sapply(split_data, nrow) > 1)
		tmp2 <- lapply(tmp, function(y) colnames(split_data[[y]][sapply(1:ncol(split_data[[y]]), function(x) any(duplicated(split_data[[y]][,x]))) == FALSE]))
		dupCols <- unique(unlist(tmp2))
		the_data <- the_data[!duplicated(the_data[,id_column]),]
		for (i in 1:length(dupCols)) {
		  the_data[,dupCols[i]] <- sapply(1:length(split_data), function(x) paste(unique(split_data[[x]][,dupCols[i]]), collapse = ";"))
		}
	}
	if ("Animal" %in% colnames(the_data) == TRUE) {
		the_data$is_animal <- ifelse(grepl("^10$|^35$|^9[8-9]$|^N$", the_data$Animal), "N", "Y")
		the_data$is_animal[the_data$Animal == "-"] <- "U"
	}
	if ("Human" %in% colnames(the_data) == TRUE) {
		the_data$is_human <- ifelse(grepl("^10$|^9[5-9]$|^N$", the_data$Human), "N", "Y")
		the_data$is_human[the_data$Human == "-"] <- "U"
	}
	if (all("Clinical.Trial" %in% colnames(the_data), "Phase.3.Trials" %in% colnames(the_data)) == TRUE) {
		the_data$is_trial <- sapply(1:nrow(the_data), function(x) ifelse(any(the_data$Clinical.Trial[x] %in% c("1", "Y"), the_data$Phase.3.Trials[x] %in% c("1", "Y")), "Y", "N"))  
	}
	if ("Stat.Grp" %in% colnames(the_data) == TRUE) {
		the_data$is_awarded <- ifelse(the_data$Stat.Grp %in% c("A", "TP", "U"), "Y", "N")
	}
	colnames(the_data) <- tolower(colnames(the_data))
	colnames(the_data) <- gsub("\\.\\.*", "_", colnames(the_data))
	colnames(the_data) <- gsub("_$", "", colnames(the_data))
	the_data[the_data == "-"] <- NA
	pcols <- which(sapply(1:ncol(the_data), function(x) sum(is.na(the_data[,x]))) == nrow(the_data))
	the_data[,pcols] <- NULL
	return(the_data)
}

# Usage
# appls <- read.csv("qvr_application_data.csv", stringsAsFactors = FALSE)
# appls <- process_qvr_data(appls)