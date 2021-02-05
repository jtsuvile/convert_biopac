# convert biopac

Takes physiological data collected with Biopac system and converts them from the proprietary .acq format to .csv files. 
Relies heavily on the [Bioread package](https://pypi.org/project/bioread/).
The output format mimics the structure of the manual conversion from the AcqKnowledge system and therefore works well with code built to handle those data, e.g. [this preprocessing pipeline](https://github.com/SDAMcIntyre/Preprocess-fEMG).
