source('/Users/juusu53/Documents/projects/femg/Preprocess-fEMG/label_femg_functions.R')
source('/Users/juusu53/Documents/projects/femg/code/averaging_functions.R')
library(RcppRoll)
library(tidyverse)
library(KernSmooth)

# Read in data
subid = 'E917_IAPS_pre_stress'
cor_file <- paste0('/Users/juusu53/Documents/projects/femg/data/preprocessed/',subid,'_Cor_preprocessed.csv')
zyg_file <- paste0('/Users/juusu53/Documents/projects/femg/data/preprocessed/',subid,'_Zyg_preprocessed.csv')
image_out <- '/Users/juusu53/Documents/projects/femg/figures/'

data_cor <- read_csv(cor_file, col_types = cols())
data_zyg <- read_csv(zyg_file, col_types = cols())

rolling_window_size=100

# edit stimulus codes
data_cor <- clean_codes(data_cor) %>% mutate(Cor.mV.smooth = roll_mean(Cor.mV, rolling_window_size, fill=NA)) %>% 
data_zyg <- clean_codes(data_zyg)%>% mutate(Zyg.mV.smooth = roll_mean(Zyg.mV, rolling_window_size, fill=NA))

smooth_cor <- data_cor %>% 
  mutate(Cor.mV.rollmean = roll_mean(Cor.mV, rolling_window_size, fill=NA)) %>% 
  mutate(Cor.mV.ksmooth = ksmooth(Time.sec, Cor.mV, "normal")) %>% 
  mutate(Cor.mV.splines = smooth_spline(Time.sec, Cor.mV))

data <- left_join(data_cor, data_zyg)

data.long <- data %>% 
  filter(Cor.flagged==FALSE, Zyg.flagged==FALSE) %>% 
  rename(Cor.mV.orig = Cor.mV, Zyg.mV.orig = Zyg.mV) %>% 
  select(Time.sec, stimTime.sec,StimCode, stim.type, stim.category, stim.social, trialNo, phase, Cor.mV.orig, Zyg.mV.orig, Cor.mV.smooth, Zyg.mV.smooth) %>% 
  pivot_longer(Cor.mV.orig:Zyg.mV.smooth, names_to = 'muscle', values_to= 'activity') %>% 
  separate(muscle, into=c('muscle','unit','type')) %>% 
  pivot_wider(values_from=activity, names_from='type') %>% 
  mutate(stimTime.sec = round(stimTime.sec, 3)) 

secondsPerSample <- diff(data_cor$Time.sec[1:2])
x.start <- -1
x.stop <- 6
win.sec <- 0.5

summary_data <- data.long %>% 
  #mutate(stimTime.sec = round(stimTime.sec,3)) %>% 
  group_by(stimTime.sec, muscle, stim.type, stim.category, stim.social) %>% 
  summarise(orig = mean(orig, na.rm=TRUE), smooth = mean(smooth, na.rm=TRUE),
            n=n())

data.long %>%
  ggplot() +
  facet_wrap(~muscle, scales = 'free_y') +
  # vertical line at stimulus onset
  geom_vline(xintercept = 0) +
  scale_fill_manual(values = '#fcae91') +
  #actual data
  geom_line(aes(x = stimTime.sec,
                y = smooth, colour = stim.category), size = 0.1, alpha=0.1) + 
  geom_line(data=summary_data, aes(x=stimTime.sec, y=smooth, col=stim.category), 
            size=2, alpha=0.7) + 
  scale_color_brewer(palette = 'Set1') +
  # general appearance
  theme_bw() + #theme(legend.position='none') +
  scale_x_continuous(
    breaks = function(x) seq(x.start, x.stop, by = win.sec*2),
    minor_breaks = function(x) seq(x.start, x.stop, by = win.sec)) +
  labs(title = paste0('Signal output from', subid),
       x = 'Time relative to stimulus onset (seconds)', y = 'mV')

ggsave('/Users/juusu53/Documents/projects/femg/figures/single_subject_singal_strenght_by_muscle.png',
       width=20, height=7)
##
# plotting density functions
##

density_estimate_pos <- data %>% drop_na() %>% filter(stim.category=='pos', phase=='stimulus') %>%
  pull(Cor.mV) %>%  
  density(., bw='SJ')
density_estimate_neg <- data %>% drop_na() %>% filter(stim.category=='neg', phase=='stimulus') %>% 
  pull(Cor.mV) %>%  
  density(., bw='SJ')
density_estimate_neu <- data %>% drop_na() %>% filter(stim.category=='neu', phase=='stimulus') %>% 
  pull(Cor.mV) %>%  
  density(., bw='SJ')

png(paste0(image_out, subid, '_density.png'))
plot(density_estimate_pos, col='red')
lines(density_estimate_neg, col='blue', add =TRUE)
lines(density_estimate_neu, col='black', add =TRUE)
dev.off()

##
# Testing out filtering functions from package 'signal'
##

rolling_window_size=200
b = (1/rolling_window_size)*rep(1,rolling_window_size)

data_cor <- data_cor %>% 
  group_by(trialNo) %>% 
  mutate(Cor.mV.filtered = stats::filter(Cor.mV, b, method='convolution', sides=2)) %>% 
  ungroup()

data_cor %>% filter(trialNo < 2) %>% 
  ggplot() +
  # vertical line at stimulus onset
  facet_wrap(~stim.category) + 
  geom_vline(xintercept = 0) +
  scale_fill_manual(values = '#fcae91') +
  #actual data
  geom_line(aes(x = stimTime.sec,
                y = Cor.mV.smooth, colour = stim.category), col='black') + 
  geom_line(aes(x = stimTime.sec,
                y = Cor.mV, colour = stim.category), col='red') + 
  geom_line(aes(x = stimTime.sec,
                y = Cor.mV.filtered, colour = stim.category), col='blue') + 
  scale_color_brewer(palette = 'Set1') +
  # general appearance
  theme_bw() + #theme(legend.position='none') +
  scale_x_continuous(
    breaks = function(x) seq(x.start, x.stop, by = win.sec*2),
    minor_breaks = function(x) seq(x.start, x.stop, by = win.sec)) +
  labs(title = paste0('Signal output from', subid),
       x = 'Time relative to stimulus onset (seconds)', y = 'mV')
