library(tidyverse)

df <- tribble(
    ~name,      ~ps1, ~ps2, ~ps3, ~lab1, ~lab2,
    "Monika",   .45,  .55,  .34,  .67,   .68,
    "Michelle", .55,  .32,  .43,  .78,   .85,
    "Madison",  .55,  .47,  .30,  .88,   .67,
    "Sanjane",  .61,  .1,   .31,  .80,   .76,
    "Matthew",  .48,  .55,  .35,  .83,   .57,
    "Nikita",   .60,  .44,  .29,  .91,   .84
             )

write_csv(df, file = "gs.csv")
