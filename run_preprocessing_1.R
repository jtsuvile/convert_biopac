#### PART 1 ####

source('/Users/juusu53/Documents/projects/femg/Preprocess-fEMG/label_femg_functions.R')
library(plotly)

#### read in the raw data ####

# For this demo, we are looking at a recording from a single session
subid = 'E917_IAPS_pre_stress'
raw.femg.file <- paste0('/Users/juusu53/Documents/projects/femg/data/converted/',subid,'.txt')

# Provide the channels in the raw data file that we are interested in
femg.ChannelNames <- c('Corr Processed',
                       'Zyg Processed',
                       'Lev Processed')
stim.ChannelName <- 'Marker'

# read the data file
raw.femg.data <- read_acq_text(fileName = raw.femg.file, 
                               delim = ',',
                               keepChannels = c(stim.ChannelName, femg.ChannelNames))

# Look at the data, it has only the channels we told it to keep, 
# and a new Time.sec channel based on the sampling rate reported 
# in the raw data file:
glimpse(raw.femg.data)

##### clean up the stimulus codes ####

# voltages on the stimulus/marker channel that indicate 
# what the stimulus was, chosen by the experimenter:

femg.stimCodes <- c(11:26, 31:46, 51:66, 71:86)

# Look for errors in the marker channel and try to fix them

labelled.femg.data <- clean_acq_stim_codes(femgData = raw.femg.data,
                                           stimChannel = stim.ChannelName,
                                           usedStimCodes = femg.stimCodes) 

# Look at the labelled data. Now we have some additional variables

glimpse(labelled.femg.data)

# Stim.flag.noise = was the voltage on the Marker channel flagged
#                   by the function as possible noise? TRUE/FALSE
# StimCode.corrected = the corrected stimulus codes
# unexpected = was the corrected stim code still something unexpected,
#               i.e. not one of the values in femg.stimCodes? TRUE/FALSE

# now check for unexpected stim codes

labelled.femg.data %>% 
  filter(unexpected) %>% 
  group_by(StimCode.corrected) %>% 
  tally()

# An uexpected voltage of 1 appears  896 times and the function
# didn't catch it. Plot the channel so we can see what's going on:

labelled.femg.data %>% 
  plot_stim_code_sequence('StimCode.corrected') %>% 
  ggplotly()

# Try zooming in on the red dots. It looks like it was produced by 
# some kind of electrical artifact so it should be safe
# to set these to 0. 

# run the clean-up again, this time telling it to set 1s to 0s 
# by adding the parameter knownNoiseCodes = c(1)
# you can add as many as you like if you find more, e.g. c(1,4,254)

labelled.femg.data <- clean_acq_stim_codes(femgData = raw.femg.data,
                                           stimChannel = stim.ChannelName,
                                           usedStimCodes = femg.stimCodes,
                                           knownNoiseCodes = c(1)) 

# check again for unexpected stim codes

labelled.femg.data %>% 
  filter(unexpected) %>% 
  group_by(StimCode.corrected) %>% 
  tally()

# now there are no unexpected values on the marker channel

labelled.femg.data %>% 
  plot_stim_code_sequence('StimCode.corrected') %>% ggplotly()


##### filling the stimulus period ####

# in this recording the stimulus markers were brief pulses
# at the stimulus onset, but we want the labels to apply
# the whole time the stimulus is switched on. We know that the 
# stimulus lasts 6 seconds so we "fill" the stimCode.corrected
# channel for the full duration of the stimulus


labelled.femg.data <- labelled.femg.data %>% 
  fill_stim_codes('StimCode.corrected', stimDuration = 6.0040)

labelled.femg.data %>% 
  plot_stim_code_sequence('StimCode.filled') %>% ggplotly()


##### check against the expected stimulus sequence ####

# next, if we have a log file from the stimulus presentation 
# software, we can check that the sequences of stimuli match
# we have a logfile from Presentation

stim.File <- '/Users/juusu53/Documents/projects/femg/data/logs/E917_IAPS_pre_stress.log'

# We use a function which is specific to this experiment, and needs to be 
# adapted for different experiments.

# here we fill the stim codes based on the log file using fillStimCodes = TRUE
comparison <- compare_stim_face_emoji_expt(femgData = labelled.femg.data,
                                           stimChannel = 'StimCode.corrected',
                                           stimFile = stim.File,
                                           fillStimCodes = TRUE)

# alternate call using our pre-filled codes
# comparison <- compare_stim_face_emoji_expt(femgData = labelled.femg.data,
#                                            stimChannel = 'StimCode.filled',
#                                            stimFile = stim.File)

# this produces a list of several objects that help with comparing the 
# expected and recorded stimulus sequence of the session

# are they synced
comparison$synced

# plot the two sequences
ggplotly(comparison$comparisonPlot)

# the timing is never exact, this shows that there were only small 
# differences between the timing of the expected and recorded times
# when the stimuli started and ended
print('Stimulus start offsets (seconds):'); print(summary(comparison$startOffsets))
print('Stimulus end offsets (seconds):'); print(summary(comparison$endOffsets))

# grab the filled data based on the stimulus log
labelled.femg.data <- comparison$stimFilledData

labelled.femg.data %>% 
  plot_stim_code_sequence('StimCode.filled') %>% ggplotly()

##### add session variables ####
# add trial numbers within the session
# add phase info (pre-stim/stim)
# add time relative to stimulus onset
labelled.femg.data <- labelled.femg.data %>% 
  add_session_variables('StimCode.filled') 

glimpse(labelled.femg.data)

# just choose the variables we want to keep
out.femg.data <- labelled.femg.data %>% 
  select(c('Time.sec',
           'stimTime.sec',
           'StimCode.filled',
           'trialNo',
           'phase',
           all_of(femg.ChannelNames))) 

out.femg.data %>% glimpse()

# save the data file
out.femg.data %>% 
  write_csv(paste0('/Users/juusu53/Documents/projects/femg/data/preprocessed/',subid,'_labelled.csv'))

