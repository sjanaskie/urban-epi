Urban Environmental Assessment Tool
==================================

This is a research tool for global urban environmental assessment.

## Requirements
All the tools used in this analysis are open source, including the data, which are freely available on the internet.
- Bash environment
- GDAL/OGR
- GRASS 7.0 or GRASS 7.2
- AWK or GAWK
- Internet connection (downloads take a long time [>1 hour] on slow internet)

## Setup
Importantly, the repo is intended to be cloned into a parent directory. 

`mkdir parent` Feel free to call this something else. In my environment, it is called urban_epi.
`git clone http://github.com/ryanthomas/urban-epi.git`

The setup script takes one of three arguements: 
- `-dir` : To set up the directory structure,
- `-data` : To download the data, and
- `-grass` : To set up the grass database.
It is necessary that these be run one at a time in this order. </br>
// Future developments may allow them to be run together with an `-all` flag.</br>

### `source/bash/setup.sh -dir`</br>
This will prompt you to enter the <i>absolute</i> path to your parent directory (chosen above). To get the absolute path to your parent directory:</br> 
- enter the directory from a bash terminal, </br> 
- type `echo $PWD` in your bash terminal, and</br>
- copy the output.

### `source/bash/setup.sh -data` </br>
This takes exceedingly long, since there are several global rasters involed. This is the main reason for splitting the process into multiple parts. Future iterations of this project may involve targeted downloading of only necessary files. 

### `source/bash/setup.sh -grass` </br>
This sets up the grassdatabase with mapsets for every city stored in carto_cities directory.

