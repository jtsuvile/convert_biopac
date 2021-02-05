source('/Users/juusu53/Documents/projects/femg/Preprocess-fEMG/label_femg_functions.R')

femgData = labelled.femg.data
stimChannel = 'StimCode.corrected'
stimFile = stim.File
fillStimCodes = TRUE
offCode = 0

#compare_stim_face_emoji_expt <- function(femgData, stimChannel, offCode = 0, stimFile, fillStimCodes = FALSE) {

# read in stim file
stimData <- suppressWarnings(
  read_tsv(stim.File, skip = 3, col_types = '__c_n__d__d_____')
) %>%
  rename('StimCode' = `Pic(num)`) %>% 
  mutate(Start.sec = Time/10000,
         Duration.sec = Duration/10000,
         End.sec = Start.sec + Duration.sec ) %>% 
  filter(`Event Type` == 'Picture' & !is.na(StimCode) & StimCode != offCode) 

# get time of first stimulus in stimulus file
stim.StartTime <- stimData %>% filter(StimCode != offCode) %>% 
  summarise(start = min(Start.sec)) %>% pull(start)

# get time of first stimulus in femg file
femgData <- femgData %>% 
  add_transitions(stimChannel)

femg.StartTime <- femgData %>% 
  filter(transition.start & .[[stimChannel]] != offCode) %>% 
  summarise(start = min(Time.sec)) %>% pull(start)

# time offset between femg and stim files
offset <- femg.StartTime - stim.StartTime

# align stimulus sequence to first stim in femg file
stimAligned <- stimData %>% 
  select(StimCode, Start.sec, Duration.sec, End.sec) %>% 
  mutate(Start.sec = Start.sec + offset,
         End.sec = End.sec + offset)

# stim sequence in femg file
femg.Seq <- femgData %>% 
  filter(transition.start & .[[stimChannel]] != offCode) %>% 
  .[[stimChannel]]

# is the sequence in the femg data file the same as in the stim data file?
synced <- length(stimData$StimCode) == length(femg.Seq)
if (synced) synced <- sum(abs(stimData$StimCode - femg.Seq)) == 0

output <- list('stimSeqData' = stimAligned, 
               'synced' = synced)

# onsets for all stimuli in femg file
femg.Start <- femgData %>% 
  filter(transition.start & .[[stimChannel]] != offCode) %>% 
  pull(Time.sec)

# offsets for all stimuli in femg file
femg.End <- femgData %>% 
  filter(transition.end & .[[stimChannel]] != offCode) %>% 
  pull(Time.sec) 

if (synced) {
  # does the timing of the start of the stimulus match?
  startOffsets <- stimAligned$Start.sec - femg.Start
  output$startOffsets <- startOffsets
  
  # does the timing of the end of the stimulus match?
  endOffsets <- stimAligned$End.sec - femg.End 
  output$endOffsets <- endOffsets
}

comparisonPlot <- ggplot() +
  geom_path(data = filter(femgData, transition.start | transition.end),
            aes(x = Time.sec, y = .data[[stimChannel]])) +
  geom_text(data = filter(femgData, transition.start & .data[[stimChannel]] != offCode),
            aes(x = Time.sec, y = .data[[stimChannel]] + 40, label = .data[[stimChannel]]),
            colour = 'black') +
  geom_point(data = stimAligned,
             aes(x = Start.sec, y = StimCode),
             colour = 'blue', shape = 3) +
  geom_text(data = stimAligned,
            aes(x = Start.sec, y = StimCode + 20, label = StimCode),
            colour = 'blue') +
  geom_point(data = stimAligned,
             aes(x = End.sec, y = offCode),
             colour = 'blue', shape = 4) +
  labs(title = 'Black: stim codes in femg file; Blue: stim codes in stim file', y = stimChannel)

output$comparisonPlot <- comparisonPlot

if (fillStimCodes) {
  stimFilledData <- femgData %>% mutate(StimCode.filled = .[[stimChannel]])
  for (n in seq_along(stimAligned$StimCode)) {
    tofill <- which(
      femgData$Time.sec > femg.Start[n] & 
        femgData$Time.sec <= femg.Start[n] + stimAligned$Duration.sec[n]
    )
    stimFilledData[tofill,'StimCode.filled'] <- stimAligned$StimCode[n]
  }
  
  stimFilledData <- stimFilledData %>% 
    add_transitions('StimCode.filled')
  
  filledPlot <- ggplot() +
    geom_path(data = filter(stimFilledData, transition.start | transition.end),
              aes(x = Time.sec, y = StimCode.filled), colour = 'darkgreen') +
    geom_text(data = filter(stimFilledData, transition.start & StimCode.filled != offCode),
              aes(x = Time.sec, y = StimCode.filled + 40, label = StimCode.filled),
              colour = 'darkgreen') +
    geom_point(data = stimAligned,
               aes(x = Start.sec, y = StimCode),
               colour = 'blue', shape = 3) +
    geom_text(data = stimAligned,
              aes(x = Start.sec, y = StimCode + 20, label = StimCode),
              colour = 'blue') +
    geom_point(data = stimAligned,
               aes(x = End.sec, y = offCode),
               colour = 'blue', shape = 4) +
    labs(title = 'Green: stim codes in femg file (duration filled from stim file); Blue: stim codes in stim file', y = stimChannel) 
  
  output$stimFilledData <- stimFilledData
  output$filledPlot <- filledPlot
  
} else {
  startmed <- median(startOffsets)
  endmed <- median(endOffsets)
  if (endmed > 3*startmed) {
    warning(paste('compare_stim_IAPS_expt()\n',
                  'offsets for the end of the stimulus are between', 
                  prettyNum(min(endOffsets)), 'and', prettyNum(max(endOffsets)), 
                  'seconds (median =', prettyNum(endmed), 
                  'seconds). \nDo you want \'fillStimCodes = TRUE\'?'))
  }
}
  
#  return(output)
  
#}
