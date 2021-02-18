# Define file path as a variable if the script and dataset are not in the same directory 

file_path = "~/Projects/R_ladies_Tbilisi/R-Ladies-Tbilisi-Talk/dataset/"

# load _tidyverse_
library(tidyverse)

# Import penguin data set
penguin_data = read_csv(str_c(file_path, "penguins_data.csv"))

# 1. Run #slice_tail and slice_sample - same syntax as slice_head from the slides
# Choose n number by yourself. See how the slice_sample gives different results every time
# What's the name of the island from the last row? 

slice_tail(penguin_data, n = 3)
slice_sample(penguin_data, n = 10)

#2. Run glimpse() and this time focus on the variable types

glimpse (penguin_data)

# Which columns have the right type and what needs to be converted? To what?
# Check out the columns called date and year. Do we need both? 

# Re-load the file running read_csv, this time specify column types we need to coerce and skip the column like ion the slides.

penguin_data02 = read_csv(str_c(file_path,"penguins_data.csv"), 
                          col_types = cols(species = col_factor(c("Adelie",  "Gentoo",  "Chinstrap")),
                                           # second column
                                           island = col_factor(c("Torgersen","Biscoe", "Dream")),
                                           # third column
                                           sex = col_factor(c("female", "male")),
                                           # skip the date column while reading the file
                                           date =  col_skip() ))


                                           

#display data structure with str(..., give.attr = FALSE) and check the conversion

str(penguin_data02, give.attr = FALSE) 

# --------- 2 ------------------
# use summary() with %>% operator

penguin_data02 %>% summary()

# --------- 3 ------------------

# Reshape penguin into tidy data - convert it into wider format like shown in the slides 

# save the output as penguin_df_wide

penguin_df_wide = penguin_data02 %>%
  pivot_wider(names_from = measurements,
              values_from = values) 



#see the first or last 10 rows and pick one of the methods to explore the data set for instance, 
#glimpse, str, dim or summary 

# --your code here-- 
#see the first 10 rows  
slice_head(penguin_df_wide, n = 8)

#see the structure of the data
glimpse(penguin_df_wide)

# --------- 4 ------------------

## Data Manipulation and Transformation Tricks

##SELECT()

# 1. Select 1st 4 rows from the data set
df1 = penguin_df_wide %>% select(species:year)
df1

#2. delete last row using select
df2 = df1 %>% select(-year)
df2

#3. Select only the columns that ends with "g" and contain word "length"
penguin_df_wide %>% select( contains ("length"), 
                            ends_with("g") )

#4. Pick 3 columns and rename using select()
penguin_df_wide %>%
  select(individual_id = id, 
         date = year,  
         location = island )

#5.  Now do the same as above but using rename() instead
penguin_df_wide %>%
  rename(individual_id = id, 
         date = year,  
         location = island )

#What's the difference ?

#6. 
penguin_df_wide %>%
  # rename id to individual_id, year - date and island - location  
  rename(individual_id = id, 
         date = year,  
         location = island ) %>%
  # Rearrange columns so that sex and id are the 1st two columns followed by the rest 
  # Which one is the correct name to use "id" or "individual_id"? 
  select(individual_id, sex,
         everything()) %>%
  # drop missing values
  drop_na() %>%
  # print the summary of the resulted data set
  summary()

#7. Relocate id to be the first column  
penguin_df_wide %>%
  relocate(id, .before = species) %>% 
  # print random 5 rows
  slice_sample(n = 5)

#8. select only the categorical columns 
penguin_df_wide %>%
  select (where (is.factor)) %>% 
  # print random 5 rows
  slice_sample(n = 5)


# -----------Changing column values with mutate()-------------

#1. Use mutate() and calculate the bill depth to length ratio
penguin_df_wide %>%  
  mutate (bill_depth_length_ratio =  bill_depth_mm / bill_length_mm ) 
  

#2. Now write the same code using transmute()
# Look at the difference

penguin_df_wide %>%  
  transmute (bill_depth_length_ratio =  bill_depth_mm / bill_length_mm )

#3. 
penguin_df_wide %>%
  # select every column that contains "mm"in name
  select(contains("mm")) %>%
  # remove missing values
  drop_na() %>%
    # round every value in these columns 
  mutate(across (everything(),
           round )
  ) 

#4. #create a new column to categorize penguins based on their flipper length - 
#equal or longer than median - long_flipper, otherwise - short_flipper

#median_flipper_length = 197mm
median_flipper_length = median(penguin_df_wide$flipper_length_mm, na.rm = T)

penguin_df_wide %>%
  #remove missing values
    drop_na() %>%
    #create a new column to categorize penguins based on their mass
    mutate(length = if_else(flipper_length_mm  >= median_flipper_length, "long_flipper", "short_flipper")) %>%
    slice_sample(n = 10)


# --------- arrange rows ---------

#1. Filter only the rows corresponding to year 2009 for female penguins only and 
#sort the rows in descending order of flipper_length
penguin_df_wide %>%
  filter(year == 2007,
         sex == "female") %>%
  arrange(desc(flipper_length_mm))

#2.
# Calculate the maximum body mass in kg of male penguins from the Biscoe island (you may use transmute())
penguin_df_wide %>%
    filter( island == "Biscoe", sex == "male") %>%
    #calculate body mass in kg
    mutate(body_mass_kg = body_mass_g / 1000) %>%
  # maximum value
    slice_max(body_mass_g)

#3. 
#Only for male penguins convert body mass to kg, group by island and species and calculate:
# - number of penguins per island and species combination
# - maximum weight in kg for each group combination

 penguin_df_wide %>%
# drop missing values
   drop_na() %>%
# filter for make penguins
   filter(sex == "male" ) %>%
# calculate body mass in kg
   mutate (body_mass_kg = body_mass_g / 1000 ) %>%
   # group by island and species
   group_by(island, species) %>%
   # calculate number of penguins per island and species combination
   summarise(penguin_number = n(),
             # and maximum weight in kg for each group combination
             max_weight = max(body_mass_kg) )%>%
   # sort it all by the descending order of weight
   arrange(desc(max_weight)
    )













