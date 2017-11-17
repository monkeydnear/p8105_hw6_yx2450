---
  title: "nyc_restaurant EDA"
runtime: shiny
output: 
  flexdashboard::flex_dashboard:
  theme: cosmo
orientation: columns
vertical_layout: fill
source_code: embed
---
  ```{r global, include=FALSE}
library(readr)
library(tidyverse)
library(janitor)
library(stringr)
library(forcats)
library(viridis)
library(plotly)
library(shiny)
library(flexdashboard)

set.seed(1)

nyc_inspections = read_csv("./data/DOHMH_New_York_City_Restaurant_Inspection_Results.csv.gz", 
                           col_types = cols(building = col_character()),
                           na = c("NA", "N/A"))


nyc_inspections =
  nyc_inspections %>%
  filter(grade %in% c("A", "B", "C"), boro != "Missing") %>% 
  mutate(boro = str_to_title(boro)) 

```



Column {.sidebar}
-----------------------------------------------------------------------
  
  ```{r}


boros = nyc_inspections %>% distinct(boro) %>% pull()

# selectInput widget
selectInput("boro_choice", label = h3("Select boro"),
            choices = boros, selected = "Manhattan")

max_score = 100
min_score = nyc_inspections %>% distinct(score) %>% select(score) %>% na.omit() %>% min()

# sliderInput widget
sliderInput("score_range", label = h3("Choose score of restaurant"), min = min_score, 
            max = max_score, value = c(10, 40))

cuisine_description = nyc_inspections %>% distinct(cuisine_description) %>% pull()

# radioButtons widget
radioButtons("cuisine_description", label = h3("Choose cuisine type"),
             choices = cuisine_description, 
             selected = "American")

```


Row
-----------------------------------------------------------------------
  
  ###  bar chart
  
  ```{r}

renderPlotly({nyc_inspections %>% 
    filter(boro == input$boro_choice) %>% 
    count(boro) %>% 
    plot_ly(x= ~boro, y = ~n, color = ~boro, type = "bar") %>% 
    layout(xaxis = list(title = "", tickangle = 45),
           yaxis = list(title = ""),
           margin = list(b = 100),
           barmode = 'group')})

```

Row {.tabset .tabset-fade}
-----------------------------------------------------------------------
  
  ### boxplot
  
  ```{r}
renderPlotly({
  nyc_inspections %>% 
    filter(cuisine_description == input$cuisine_description,
           score %in% input$score_range[1]:input$score_range[2]) %>%
    mutate(cuisine_description = fct_reorder(cuisine_description, score)) %>%
    plot_ly(y = ~score, color = ~cuisine_description, type = "box",
            colors = "Set2") %>% 
    layout(xaxis = list(title = "", tickangle = 45),
           yaxis = list(title = ""),
           margin = list(b = 100),
           barmode = 'group',
           showlegend = FALSE)
})
```



