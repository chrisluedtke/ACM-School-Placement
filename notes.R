df <- data.frame(a = 1, b = 2)

df$sum <- df$a + df$b
df$sum2 <- with(df, a + b)
df <- within(df, sum3 <- a + b)


mylist <- list(a = 5, b = letters[1:3], c = data.frame(col1 = 1:5, col2 = 6:10))
mylist[1] # this gets the first train car
mylist[[1]] # This opens the *contents* of the first train car

unlist(mylist)

# Use already-loaded mtcars data set to contrast grep() methods
models <- rownames(mtcars)
grep("Merc", models) # Returns position numbers
grepl("Merc", models) # REturns true and false indicating whether the text was found in the corresponding position
grep("Merc", models, value = TRUE) # Returns the strings that matched the pattern
grepv <- function(pat, x, ...) grep(pat, x, value = TRUE, ...)
grepv("Merc", models)
