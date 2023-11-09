process_qvr_data <- function(the_data, id_column = "Appl.Id") {
	the_data <- unique(the_data)
	if (sum(duplicated(the_data[,id_column])) > 0) {
		split_data <- split(the_data, the_data[,id_column])
		tmp <- which(sapply(split_data, nrow) > 1)
		tmp2 <- lapply(tmp, function(y) colnames(split_data[[y]][sapply(1:ncol(split_data[[y]]), function(x) length(unique(split_data[[y]][,x]))) > 1]))
		dupCols <- unique(unlist(tmp2))
		the_data <- the_data[!duplicated(the_data[,id_column]),]
		the_data <- the_data[order(the_data[,id_column]),] ## split_data is ordered by id_column, so need to order the_data the same way to ensure the values match
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
		the_data$is_awarded <- ifelse(the_data$Stat.Grp %in% c("A", "TP", "U", "T"), "Y", "N")
	}
	if ("Inst.Type" %in% colnames(the_data) == TRUE) {
		the_data$inst_type_desc[the_data$Inst.Type == 10] <- "Higher education"
		the_data$inst_type_desc[the_data$Inst.Type == 20] <- "Research organization"
		the_data$inst_type_desc[the_data$Inst.Type == 30] <- "Independent hospital"
		the_data$inst_type_desc[the_data$Inst.Type == 40] <- "Other education"
		the_data$inst_type_desc[is.na(the_data$inst_type_desc)] <- "Other"
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


## before doing this for each file, replace the [sub] box with a space " " in notepad++ for each file
## this function also assumes there are only two columns in the abstract data frame [appl_id, abstracts], so this only works for data in that structure
clean_abstracts <- function(filepath, overwrite = FALSE) {
	the_abstracts <- scan(filepath, what = "varchar", sep = "\n", quiet = TRUE, skipNul = TRUE)
	the_abstracts <- sapply(the_abstracts, iconv, to = "ASCII", sub = " ")
	prob_lines <- which(grepl("\",\".+\",\".+", the_abstracts))
	while (length(prob_lines) > 0) {
	  the_abstracts <- gsub("(\",\".+)(\",\")(.+)", "\\1 \\3", the_abstracts)
	  prob_lines <- which(grepl("\",\".+\",\".+", the_abstracts))
	}
	the_abstracts <- gsub("(?<!\",)$", "\",", the_abstracts, perl = TRUE)
	if (overwrite == TRUE) {
	  writeLines(the_abstracts, con = filepath)
	}
	else {
	  filepath <- gsub("(\\.[a-z]{3,4}$)", "_cleaned\\1", filepath)
	  writeLines(the_abstracts, con = filepath)
	}
	message("Done")
}
## what I'm essentially doing here is reading in the csv as a vector of character strings so that the extra commas don't hurt anything
## I then look for the "," string of characters after the first column (i.e. a second occurrence of that string, which indicates an incorrect column break)
## I then gsub the second "," substring out of the main string by retaining just the substrings on either side of the problem substring
## This means I need to do that multiple times if there are multiple "," substrings in the main string, thus the 'while' loop

