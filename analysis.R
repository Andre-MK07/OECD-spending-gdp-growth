## load packages

library (tidyverse)
library (ggplot2)
library(plm) ## panel data regression
library(stargazer) ## regression tables
library(corrplot) ## correlation matrix plot
library(readxl) 

## Load and clean data from OECD dataset

oecd<- read.csv("oecdspending.csv")
View(oecd)
dim(oecd)
names(oecd)
head(oecd,5)
                ## select only the 4 relevant columns

mean(oecd$REF_AREA)
mean(oecd$EXPENDITURE)
mean(oecd$TIME_PERIOD)
mean(oecd$OBS_VALUE)

oecd_clean <- oecd%>%
  select(REF_AREA, EXPENDITURE, TIME_PERIOD, OBS_VALUE )
head(oecd_clean,10) ## get first 10 rows
unique(oecd_clean$EXPENDITURE) ## this gives 5 key categories: Total government expenditure,
                               # health, education, economic affairs and social protection

oecd_clean <- oecd_clean %>% ## clean data with the 5 key categories
  filter(EXPENDITURE %in% c("_T", "GF04", "GF07", "GF09", "GF10")) %>%
  mutate(category = recode(EXPENDITURE,
   "_T"   = "total",
    "GF04" = "health",
    "GF07" = "education",
    "GF09" = "econ_affairs",
   "GF10" = "social_protection"
  ))
head(oecd_clean, 10)
 dim(oecd_clean)
 unique(oecd_clean$TIME_PERIOD)
  
      ## seek and select for spending category
 
 oecd_wide<- oecd_clean %>%
   select(REF_AREA, TIME_PERIOD,category,OBS_VALUE) %>%
   pivot_wider(names_from = category,values_from = OBS_VALUE)
 head(oecd_wide,10) 
  
    ## filter data
 
 oecd_wide<-oecd_wide %>%
   filter(nchar(REF_AREA)==3) %>%
   mutate(
     health_share= health / total*100 ,
     social_share= social_protection / total*100 ,
     econ_share= econ_affairs / total*100 ,
     educ_share= education / total*100
     )
 head(oecd_wide,10)
 oecd_wide %>%
   select(REF_AREA,TIME_PERIOD,health_share,social_share,econ_share,educ_share) %>%
 head(10)
 view(oecd_wide)
 
  ## load and clean GDP growth data
 
gdp_raw<-read.csv("GDPgrowthAPI.csv", skip=4) # skip 4 metadata rows
head(gdp_raw,5)
names(gdp_raw)
view(gdp_raw)

gdp_long<- gdp_raw %>% ## convert wide format to long format
  select(Country.Name,Country.Code, X2000:X2022) %>%
  pivot_longer(
    cols = X2000:X2022 ,
  names_to="year" ,
 values_to="gdp_growth" 
 ) %>%
  mutate(year=as.integer(gsub("X", "",year))) %>%
  filter(!is.na(gdp_growth))

head(gdp_long,10)
dim(gdp_long)

  ## With clean data, merge datasets to match country names

  ## merge OECD spending and World Bank GDP data on country code and year

panel <- left_join(oecd_wide, gdp_long, by = c("REF_AREA" = "Country.Code", 
                                               "TIME_PERIOD" = "year"))
dim(panel)
head(panel)
view(panel)
sum(is.na(panel$gdp_growth)) ## confirm for missing values
n_distinct(panel$REF_AREA) ## check for total countries

## Plots and Descriptive analysis

panel %>%
  filter(TIME_PERIOD==2019) %>%
  ggplot(aes(x = reorder(REF_AREA, health_share), y = health_share)) +
  geom_col() +
  coord_flip() +
  labs(title = "Health Spending as % of Total Government Expenditure (2019)",
       x = NULL, y = "% of total expenditure") ##Plot the countries that spend most on health

panel %>% ## build health_share scatterplot to see the relation with GDP growth
  ggplot(aes(x = health_share, y = gdp_growth)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Health Spending vs GDP Growth",
       x = "Health share (% of total expenditure)",
       y = "GDP growth (%)")

panel %>% ## see the relation now with social_share
  
  ggplot(aes(x = social_share, y = gdp_growth)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Social share vs GDP Growth",
       x = "Social share (% of total expenditure)",
       y = "GDP growth (%)") 

panel %>% ## see the relation now with econ_share
  
  ggplot(aes(x = econ_share, y = gdp_growth)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Econ share vs GDP Growth",
       x = "Econ share (% of total expenditure)",
       y = "GDP growth (%)") 

##Correlation matrix

#build correlation matrix to understand relationships between variables, and spot if there is multicollinearity

cor_data <- panel %>% 
  select(gdp_growth, health_share, social_share, econ_share, educ_share) %>%
  drop_na()

cor_matrix <- cor(cor_data)
corrplot(cor_matrix, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black",
         title = "Correlation Matrix", mar = c(0,0,2,0))

## build a panel linear model with gdp_growth as the dependent variable
# and health_share, social_share, econ_share and_educ share as independent variables.
# Set for first model no fixed effects, second with one way fixed effects and last for two ways fixed effects

pdata<- pdata.frame(panel,index = c("REF_AREA","TIME_PERIOD"))

mod1<- plm(gdp_growth ~ health_share + social_share + econ_share +educ_share,
         data=pdata,model ="pooling" )
summary(mod1) ## ignores country differences, does not account for fixed effects

## build second model with one way fixed effects

mod2 <- plm(gdp_growth ~ health_share + social_share + econ_share + educ_share,
          data = pdata, model = "within", effect = "individual")
summary(mod2) ## this gives one way fixed effects, combining country level differences with actual effects

## build third model with two way fixed effects, country and year.

mod3 <- plm(gdp_growth ~ health_share + social_share + econ_share + educ_share,
          data = pdata, model = "within", effect = "twoways")
summary(mod3) ## this gives a confirmation of social_share being consistent and significant, just like econ_share

## confirm with F-test, if fixed effects are needed

pFtest(mod2, mod1) ## we get that countries differ significantly from each other in ways that matter for GDP growth, 
                   # so the pooled OLS was wrong to ignore that.Model 2 and 3 are the correct ones to use.

## build regression table combining three models

stargazer(mod1, mod2, mod3, type = "text",
          column.labels = c("Pooled OLS", "Country FE", "Two-Way FE"),
          covariate.labels = c("Health share", "Social protection share",
                               "Economic affairs share", "Education share"),
          dep.var.labels = "GDP Growth (%)")
