if (!require(tidyverse)) install.packages(tidyverse); library(tidyverse)

clean_codes <- function(data){
  
  for (trial in unique(data$trialNo)) {
    stimCodesToChooseFrom <- data %>% filter(trialNo == trial) %>% distinct(StimCode)
    useStimCode <- max(stimCodesToChooseFrom)
    data[data$trialNo == trial & data$StimCode == 0, 'StimCode'] <- useStimCode
  }
  
  data <- data %>% 
    mutate(stim.type = case_when(StimCode > 10 & StimCode < 20 ~ 'nssi_soc', StimCode > 20 & StimCode < 30 ~ 'nssi_ns',
                                 StimCode > 30 & StimCode < 40 ~ 'pos_soc', StimCode > 40 & StimCode < 50 ~ 'pos_ns',
                                 StimCode > 50 & StimCode < 60 ~ 'neu_soc', StimCode > 60 & StimCode < 70 ~ 'neu_ns',
                                 StimCode > 70 & StimCode < 80 ~ 'neg_soc', StimCode > 80 & StimCode < 90 ~ 'neg_ns')) 
  
  data  <- data %>% 
    separate(stim.type, into=c('stim.category', 'stim.social'), remove=FALSE)
  return(data)
}

rms <- function(num){
  rms <- sqrt(sum(num^2)/length(num))
  return(rms)
} 

slide_rms <- function(data, windowSize, boundaryCol = FALSE){
  rms_data <- rep(NA, length(data))
  pre_window = floor(windowSize/2)
  post_window = ceiling(windowSize/2)
  location = pre_window
  while(location < length(data)-post_window){
    rms_data[location] = rms(data[location-pre_window:location+post_window])
    location = location + 1
  }
  return(rms_data)
}